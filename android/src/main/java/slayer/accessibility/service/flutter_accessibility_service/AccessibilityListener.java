package slayer.accessibility.service.flutter_accessibility_service;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
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

    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final int eventType = accessibilityEvent.getEventType();
        AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();

        if (parentNodeInfo == null) {
            return;
        }

        String packageName = parentNodeInfo.getPackageName().toString();

        Log.d("X-SLAYER", packageName + "  :  " + eventType);

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
        sendBroadcast(intent);
    }

    @Override
    public void onInterrupt() {

    }
}
