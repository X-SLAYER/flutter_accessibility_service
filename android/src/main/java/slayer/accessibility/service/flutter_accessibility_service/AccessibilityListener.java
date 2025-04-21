package slayer.accessibility.service.flutter_accessibility_service;

import static slayer.accessibility.service.flutter_accessibility_service.Constants.*;
import static slayer.accessibility.service.flutter_accessibility_service.FlutterAccessibilityServicePlugin.CACHED_TAG;

import android.accessibilityservice.AccessibilityService;
import android.annotation.TargetApi;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.util.LruCache;
import android.view.Gravity;
import android.view.WindowManager;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityWindowInfo;

import androidx.annotation.RequiresApi;


import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.HashSet;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

import io.flutter.embedding.android.FlutterTextureView;
import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngineCache;


public class AccessibilityListener extends AccessibilityService {
    private static final String TAG = "AccessibilityListener";
    private static WindowManager mWindowManager;
    private static FlutterView mOverlayView;
    static private boolean isOverlayShown = false;
    private static final int CACHE_SIZE = 4 * 1024 * 1024; // 4MiB
    private static final LruCache<String, AccessibilityNodeInfo> nodeMap =
            new LruCache<>(CACHE_SIZE);

    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    private static final int EVENT_PROCESSING_TIMEOUT_SECONDS = 2;
    public static AccessibilityNodeInfo getNodeInfo(String id) {
        return nodeMap.get(id);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();
        if (parentNodeInfo == null) {
            return;
        }

        final AccessibilityEvent eventCopy = AccessibilityEvent.obtain(accessibilityEvent);
        final int eventType = eventCopy.getEventType();

        Callable<Void> task = () -> {
            try {
                processAccessibilityEvent(eventCopy, parentNodeInfo);
                return null;
            } catch (Exception ex) {
                Log.e(TAG, "Error processing accessibility event: " + ex.getMessage(), ex);
                return null;
            } finally {
                eventCopy.recycle(); // Clean up the copied event
            }
        };

        Future<Void> future = executor.submit(task);
        try {
            // Wait up to configured seconds for processing to complete
            future.get(EVENT_PROCESSING_TIMEOUT_SECONDS, TimeUnit.SECONDS);
        } catch (TimeoutException e) {
            future.cancel(true);
            Log.w(TAG, "Event processing timed out for event type: " + eventType);
            // Notify that event processing was canceled
            Intent timeoutIntent = new Intent(ACCESSIBILITY_INTENT);
            timeoutIntent.putExtra("event_timeout", true);
            timeoutIntent.putExtra("event_type", eventType);
            sendBroadcast(timeoutIntent);
        } catch (Exception e) {
            Log.e(TAG, "Exception while waiting for event processing: " + e.getMessage(), e);
        }

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        boolean globalAction = intent.getBooleanExtra(INTENT_GLOBAL_ACTION, false);
        boolean systemActions = intent.getBooleanExtra(INTENT_SYSTEM_GLOBAL_ACTIONS, false);
        if (systemActions && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            List<Integer> actions = getSystemActions().stream().map(AccessibilityNodeInfo.AccessibilityAction::getId).collect(Collectors.toList());
            Intent broadcastIntent = new Intent(BROD_SYSTEM_GLOBAL_ACTIONS);
            broadcastIntent.putIntegerArrayListExtra("actions", new ArrayList<>(actions));
            sendBroadcast(broadcastIntent);
        }
        if (globalAction) {
            int actionId = intent.getIntExtra(INTENT_GLOBAL_ACTION_ID, 8);
            performGlobalAction(actionId);
        }
        Log.d("CMD_STARTED", "onStartCommand: " + startId);
        return START_STICKY;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    private void processAccessibilityEvent(AccessibilityEvent accessibilityEvent, AccessibilityNodeInfo parentNodeInfo) {
        try {
            final int eventType = accessibilityEvent.getEventType();
            AccessibilityWindowInfo windowInfo = null;
            List<String> nextTexts = new ArrayList<>();
            List<Integer> actions = new ArrayList<>();
            List<HashMap<String, Object>> subNodeActions = new ArrayList<>();
            HashSet<AccessibilityNodeInfo> traversedNodes = new HashSet<>();
            HashMap<String, Object> data = new HashMap<>();

            String nodeId = generateNodeId(parentNodeInfo);
            String packageName = parentNodeInfo.getPackageName().toString();
            storeNode(nodeId, parentNodeInfo);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                windowInfo = parentNodeInfo.getWindow();
            }

            Intent intent = new Intent(ACCESSIBILITY_INTENT);

            data.put("mapId", nodeId);
            data.put("packageName", packageName);
            data.put("eventType", eventType);
            data.put("actionType", accessibilityEvent.getAction());
            data.put("eventTime", accessibilityEvent.getEventTime());
            data.put("movementGranularity", accessibilityEvent.getMovementGranularity());

            Rect rect = new Rect();
            parentNodeInfo.getBoundsInScreen(rect);
            data.put("screenBounds", getBoundingPoints(rect));

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                data.put("contentChangeTypes", accessibilityEvent.getContentChangeTypes());
            }

            if (parentNodeInfo.getText() != null) {
                data.put("capturedText", parentNodeInfo.getText().toString());
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                data.put("nodeId", parentNodeInfo.getViewIdResourceName());
            }

            getSubNodes(parentNodeInfo, subNodeActions, traversedNodes,10);
            data.put("nodesText", nextTexts);
            actions.addAll(parentNodeInfo.getActionList().stream()
                    .map(AccessibilityNodeInfo.AccessibilityAction::getId)
                    .collect(Collectors.toList()));

            data.put("parentActions", actions);
            data.put("subNodesActions", subNodeActions);
            data.put("isClickable", parentNodeInfo.isClickable());
            data.put("isScrollable", parentNodeInfo.isScrollable());
            data.put("isFocusable", parentNodeInfo.isFocusable());
            data.put("isCheckable", parentNodeInfo.isCheckable());
            data.put("isLongClickable", parentNodeInfo.isLongClickable());
            data.put("isEditable", parentNodeInfo.isEditable());

            if (windowInfo != null) {
                data.put("isActive", windowInfo.isActive());
                data.put("isFocused", windowInfo.isFocused());
                data.put("windowType", windowInfo.getType());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    data.put("isPip", windowInfo.isInPictureInPictureMode());
                }
            }

            storeToSharedPrefs(data);
            intent.putExtra(SEND_BROADCAST, true);
            sendBroadcast(intent);
        } catch (Exception ex) {
            Log.e(TAG, "Error in processAccessibilityEvent: " + ex.getMessage(), ex);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    void getSubNodes(AccessibilityNodeInfo node, List<HashMap<String, Object>> arr, HashSet<AccessibilityNodeInfo> traversedNodes,int currentDepth) {
        if (currentDepth > 10) return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            if (traversedNodes.contains(node)) return;
            traversedNodes.add(node);
            String mapId = generateNodeId(node);
            AccessibilityWindowInfo windowInfo = null;
            HashMap<String, Object> nested = new HashMap<>();
            Rect rect = new Rect();
            node.getBoundsInScreen(rect);
            windowInfo = node.getWindow();
            nested.put("mapId", mapId);
            nested.put("nodeId", node.getViewIdResourceName());
            if (node.getText() != null) {
                nested.put("capturedText", node.getText());
            }
            nested.put("screenBounds", getBoundingPoints(rect));
            if (node.isClickable() || node.isScrollable() || node.isEditable()) {
                nested.put("isClickable", node.isClickable());
                nested.put("isScrollable", node.isScrollable());
                nested.put("isEditable", node.isEditable());
            }
            nested.put("isFocusable", node.isFocusable());
            nested.put("isCheckable", node.isCheckable());
            nested.put("isLongClickable", node.isLongClickable());
            nested.put("parentActions", node.getActionList().stream()
                    .map(AccessibilityNodeInfo.AccessibilityAction::getId)
                    .collect(Collectors.toList()));
            if (windowInfo != null) {
                nested.put("isActive", node.getWindow().isActive());
                nested.put("isFocused", node.getWindow().isFocused());
                nested.put("windowType", node.getWindow().getType());
            }
            arr.add(nested);
            storeNode(mapId, node);
            for (int i = 0; i < node.getChildCount(); i++) {
                AccessibilityNodeInfo child = node.getChild(i);
                if (child == null)
                    continue;
                getSubNodes(child, arr, traversedNodes,currentDepth+1);
            }
        }
    }

    private HashMap<String, Integer> getBoundingPoints(Rect rect) {
        HashMap<String, Integer> frame = new HashMap<>();
        frame.put("left", rect.left);
        frame.put("right", rect.right);
        frame.put("top", rect.top);
        frame.put("bottom", rect.bottom);
        frame.put("width", rect.width());
        frame.put("height", rect.height());
        return frame;
    }


    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP_MR1)
    @Override
    protected void onServiceConnected() {
        mWindowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        mOverlayView = new FlutterView(getApplicationContext(), new FlutterTextureView(getApplicationContext()));
        mOverlayView.attachToFlutterEngine(Objects.requireNonNull(FlutterEngineCache.getInstance().get(CACHED_TAG)));
        mOverlayView.setFitsSystemWindows(true);
        mOverlayView.setFocusable(true);
        mOverlayView.setFocusableInTouchMode(true);
        mOverlayView.setBackgroundColor(Color.TRANSPARENT);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP_MR1)
    static public void showOverlay() {
      try
      {
          if (!isOverlayShown) {
              WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
              lp.type = WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY;
              lp.format = PixelFormat.TRANSLUCENT;
              lp.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
              lp.width = WindowManager.LayoutParams.MATCH_PARENT;
              lp.height = WindowManager.LayoutParams.MATCH_PARENT;
              lp.gravity = Gravity.TOP;
              mWindowManager.addView(mOverlayView, lp);
              isOverlayShown = true;
          }
      } catch (Exception e) {
          Log.e(TAG, "Error showing overlay", e);
      }
    }

    static public void removeOverlay() {
        if (isOverlayShown) {
            mWindowManager.removeView(mOverlayView);
            isOverlayShown = false;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        removeOverlay();
        executor.shutdown();
        try {
            if (!executor.awaitTermination(5, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
        SharedPreferences sharedPreferences = getSharedPreferences(SHARED_PREFS_TAG, MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove(ACCESSIBILITY_NODE).apply();
    }

    @Override
    public void onInterrupt() {
    }


    private String generateNodeId(AccessibilityNodeInfo node) {
        return node.getWindowId() + "_" + node.getClassName() + "_" + node.getText() + "_" + node.getContentDescription(); //UUID.randomUUID().toString();
    }

    private void storeNode(String uuid, AccessibilityNodeInfo node) {
        if (node == null) {
            return;
        }
        nodeMap.put(uuid, node);
    }

    void storeToSharedPrefs(HashMap<String, Object> data) {
        SharedPreferences sharedPreferences = getSharedPreferences(SHARED_PREFS_TAG, MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        Gson gson = new Gson();
        String json = gson.toJson(data);
        editor.putString(ACCESSIBILITY_NODE, json);
        editor.apply();
    }

}
