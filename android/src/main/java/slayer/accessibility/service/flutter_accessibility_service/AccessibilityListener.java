package slayer.accessibility.service.flutter_accessibility_service;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;

public class AccessibilityListener extends AccessibilityService {

    public static String ACCESSIBILITY_INTENT = "accessibility_event";
    public static String ACCESSIBILITY_NAME = "accessibility_name";


    @Override
    public void onAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        final int eventType = accessibilityEvent.getEventType();
        AccessibilityNodeInfo parentNodeInfo = accessibilityEvent.getSource();
        if (parentNodeInfo == null) {
            return;
        }
        String packageName = parentNodeInfo.getPackageName().toString();
        Log.d("ACCESSIBILITY_SLAYER", packageName + "  :  " + eventType);
        // Pass data from one activity to another.
        Intent intent = new Intent(ACCESSIBILITY_INTENT);
        intent.putExtra(ACCESSIBILITY_NAME, packageName);
        sendBroadcast(intent);
    }

    @Override
    public void onInterrupt() {

    }
}
