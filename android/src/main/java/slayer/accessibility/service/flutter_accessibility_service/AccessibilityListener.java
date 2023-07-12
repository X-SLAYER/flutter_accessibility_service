package slayer.accessibility.service.flutter_accessibility_service;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityWindowInfo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class AccessibilityListener extends AccessibilityService {

    public static String ACCESSIBILITY_INTENT = "accessibility_event";
    public static String ACCESSIBILITY_NAME = "packageName";
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

    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final int eventType = accessibilityEvent.getEventType();
        AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();
        AccessibilityWindowInfo windowInfo = null;
        List<String> nextTexts = new ArrayList<>();
        List<AccessibilityNodeInfo> traversedNodes = new ArrayList<>();

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
        getNextTexts(parentNodeInfo, nextTexts, traversedNodes);

        //Gets the text of sub nodes.
        intent.putStringArrayListExtra(ACCESSIBILITY_NODES_TEXT, (ArrayList<String>) nextTexts);

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


    void getNextTexts(AccessibilityNodeInfo node, List<String> arr, List<AccessibilityNodeInfo> traversedNodes) {
        if (node == null) return;
        if (traversedNodes.contains(node)) return;
        // if it's not traversed visit it
        traversedNodes.add(node);
        // prefer content description over text, following android talkback src code
        // https://github.com/google/talkback/blob/bdead86e21beae508fa1fd7a24a06608485e1c29/utils/src/main/java/com/google/android/accessibility/utils/AccessibilityNodeInfoUtils.java#L368
        String nodeText = "";
        if (node.isVisibleToUser()) {
            if (node.getContentDescription() != null && node.getContentDescription().length() > 0) {
                nodeText = node.getContentDescription().toString();
            } else {
                if (node.getText() != null && node.getText().length() > 0) {
                    nodeText = node.getText().toString();
                }
            }
        }
        if (!nodeText.isEmpty()) {
            arr.add(nodeText);
        }
        
        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            getNextTexts(child, arr, traversedNodes);
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
