package slayer.accessibility.service.flutter_accessibility_service;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.os.Build;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityWindowInfo;

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

    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final int eventType = accessibilityEvent.getEventType();
        AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();
        AccessibilityWindowInfo windowInfo = null;

        if (parentNodeInfo == null) {
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            windowInfo = parentNodeInfo.getWindow();
        }

        String packageName = parentNodeInfo.getPackageName().toString();

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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            //Gets the bit mask of change types signaled by a TYPE_WINDOW_CONTENT_CHANGED event or TYPE_WINDOW_STATE_CHANGED. A single event may represent multiple change types.
            intent.putExtra(ACCESSIBILITY_CHANGES_TYPES, accessibilityEvent.getContentChangeTypes());
        }
        if (parentNodeInfo.getText() != null) {
            //Gets the text of this node.
            intent.putExtra(ACCESSIBILITY_TEXT, parentNodeInfo.getText().toString());
        }
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
    public void onInterrupt() {

    }
}
