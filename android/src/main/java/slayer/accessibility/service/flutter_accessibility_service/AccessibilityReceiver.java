package slayer.accessibility.service.flutter_accessibility_service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class AccessibilityReceiver extends BroadcastReceiver {

    private EventChannel.EventSink eventSink;

    public AccessibilityReceiver(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        /// Send data back via the Event Sink
        HashMap<String, Object> data = new HashMap<>();
        data.put("packageName", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_NAME));
        data.put("eventType", intent.getIntExtra(AccessibilityListener.ACCESSIBILITY_EVENT_TYPE, -1));
        data.put("capturedText", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_TEXT));
        data.put("actionType", intent.getIntExtra(AccessibilityListener.ACCESSIBILITY_ACTION, -1));
        data.put("eventTime", intent.getLongExtra(AccessibilityListener.ACCESSIBILITY_EVENT_TIME, -1));
        data.put("contentChangeTypes", intent.getIntExtra(AccessibilityListener.ACCESSIBILITY_CHANGES_TYPES, -1));
        data.put("movementGranularity", intent.getIntExtra(AccessibilityListener.ACCESSIBILITY_MOVEMENT, -1));
        data.put("isActive", intent.getBooleanExtra(AccessibilityListener.ACCESSIBILITY_IS_ACTIVE, false));
        data.put("isFocused", intent.getBooleanExtra(AccessibilityListener.ACCESSIBILITY_IS_FOCUSED, false));
        data.put("isPip", intent.getBooleanExtra(AccessibilityListener.ACCESSIBILITY_IS_PIP, false));
        data.put("windowType", intent.getIntExtra(AccessibilityListener.ACCESSIBILITY_WINDOW_TYPE, -1));
        data.put("screenBounds", intent.getSerializableExtra(AccessibilityListener.ACCESSIBILITY_SCREEN_BOUNDS));
        data.put("nodesText" , intent.getStringArrayListExtra(AccessibilityListener.ACCESSIBILITY_NODES_TEXT));
        eventSink.success(data);
    }
}
