package slayer.accessibility.service.flutter_accessibility_service;

import android.accessibilityservice.AccessibilityService;
import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityWindowInfo;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;


public class AccessibilityListener extends AccessibilityService {

    private static AccessibilityNodeInfo nodeInfo;

    public static AccessibilityNodeInfo getNodeInfo() {
        return nodeInfo;
    }


    public static String ACCESSIBILITY_INTENT = "accessibility_event";
    public static String ACCESSIBILITY_NAME = "packageName";
    public static String ACCESSIBILITY_NODE_ID = "nodeId";
    public static String ACCESSIBILITY_EVENT_TYPE = "eventType";
    public static String ACCESSIBILITY_TEXT = "capturedText";
    public static String ACCESSIBILITY_ACTION = "action";
    public static String ACCESSIBILITY_EVENT_TIME = "eventTime";
    public static String ACCESSIBILITY_CHANGES_TYPES = "contentChangeTypes";
    public static String ACCESSIBILITY_MOVEMENT = "movementGranularity";
    public static String ACCESSIBILITY_IS_ACTIVE = "isActive";
    public static String ACCESSIBILITY_IS_FOCUSED = "isFocused";
    public static String ACCESSIBILITY_IS_PIP = "isInPictureInPictureMode";
    public static String ACCESSIBILITY_WINDOW_TYPE = "windowType";
    public static String ACCESSIBILITY_SCREEN_BOUNDS = "screenBounds";
    public static String ACCESSIBILITY_NODES_TEXT = "nodesText";
    public static final String INTENT_TAKE_SCREENSHOT = "TakeScreenshot";
    public static final String ACTION_LIST = "actionList";
    public static final String SUB_NODES_ACTIONS = "subNodesActionList";

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final int eventType = accessibilityEvent.getEventType();
        AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();
        AccessibilityWindowInfo windowInfo = null;
        List<String> nextTexts = new ArrayList<>();
        List<Integer> actions = new ArrayList<>();
        HashMap<String, List<Integer>> subNodeActions = new HashMap<>();
        nodeInfo = parentNodeInfo;
        if (parentNodeInfo == null) {
            return;
        }

        String packageName = parentNodeInfo.getPackageName().toString();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            windowInfo = parentNodeInfo.getWindow();
        }


        Intent intent = new Intent(ACCESSIBILITY_INTENT);
        //Gets the package name of the source
        intent.putExtra(ACCESSIBILITY_NAME, packageName);
        //Gets the event type
        intent.putExtra(ACCESSIBILITY_EVENT_TYPE, eventType);
        //Gets the performed action that triggered this event.
        intent.putExtra(ACCESSIBILITY_ACTION, accessibilityEvent.getAction());
        //Gets The event time.
        intent.putExtra(ACCESSIBILITY_EVENT_TIME, accessibilityEvent.getEventTime());
        //Gets the movement granularity that was traversed.
        intent.putExtra(ACCESSIBILITY_MOVEMENT, accessibilityEvent.getMovementGranularity());

        // Gets the node bounds in screen coordinates.
        Rect rect = new Rect();
        parentNodeInfo.getBoundsInScreen(rect);
        intent.putExtra(ACCESSIBILITY_SCREEN_BOUNDS, getBoundingPoints(rect));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            //Gets the bit mask of change types signaled by a TYPE_WINDOW_CONTENT_CHANGED event or TYPE_WINDOW_STATE_CHANGED. A single event may represent multiple change types.
            intent.putExtra(ACCESSIBILITY_CHANGES_TYPES, accessibilityEvent.getContentChangeTypes());
        }
        if (parentNodeInfo.getText() != null) {
            //Gets the text of this node.
            intent.putExtra(ACCESSIBILITY_TEXT, parentNodeInfo.getText().toString());
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            intent.putExtra(ACCESSIBILITY_NODE_ID, parentNodeInfo.getViewIdResourceName());
        }
        getNextTexts(parentNodeInfo, nextTexts);
        getIdResourceNames(parentNodeInfo, subNodeActions);
        //Gets the text of sub nodes.
        intent.putStringArrayListExtra(ACCESSIBILITY_NODES_TEXT, (ArrayList<String>) nextTexts);
        actions.addAll(parentNodeInfo.getActionList().stream().map(AccessibilityNodeInfo.AccessibilityAction::getId).collect(Collectors.toList()));
        //Gets actions this nodes.
        intent.putIntegerArrayListExtra(ACTION_LIST, (ArrayList<Integer>) actions);
        intent.putExtra(SUB_NODES_ACTIONS, subNodeActions);
        if (windowInfo != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Gets if this window is active.
                intent.putExtra(ACCESSIBILITY_IS_ACTIVE, windowInfo.isActive());
                // Gets if this window has input focus.
                intent.putExtra(ACCESSIBILITY_IS_FOCUSED, windowInfo.isFocused());
                // Gets the type of the window.
                intent.putExtra(ACCESSIBILITY_WINDOW_TYPE, windowInfo.getType());
                // Check if the window is in picture-in-picture mode.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    intent.putExtra(ACCESSIBILITY_IS_PIP, windowInfo.isInPictureInPictureMode());
                }

            }
        }
        sendBroadcast(intent);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        boolean takeScreenShot = intent.getBooleanExtra(INTENT_TAKE_SCREENSHOT, false);
        if (takeScreenShot) {
            performGlobalAction(AccessibilityService.GLOBAL_ACTION_TAKE_SCREENSHOT);
        }
        Log.d("CMD_STARTED", "onStartCommand: " + startId);
        return START_STICKY;
    }

    void getNextTexts(AccessibilityNodeInfo node, List<String> arr) {
        if (node.getText() != null && node.getText().length() > 0)
            arr.add(node.getText().toString());
        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            if (child == null)
                continue;
            getNextTexts(child, arr);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    void getIdResourceNames(AccessibilityNodeInfo node, HashMap<String, List<Integer>> arr) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            if (node.getViewIdResourceName() != null && node.getViewIdResourceName().length() > 0) {
                arr.put(node.getViewIdResourceName(), node.getActionList().stream().map(AccessibilityNodeInfo.AccessibilityAction::getId).collect(Collectors.toList()));
            }
            for (int i = 0; i < node.getChildCount(); i++) {
                AccessibilityNodeInfo child = node.getChild(i);
                if (child == null)
                    continue;
                getIdResourceNames(child, arr);
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

    @Override
    public void onInterrupt() {
    }
}
