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
        data.put("eventType", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_EVENT_TYPE));
        data.put("capturedText", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_TEXT));
        data.put("actionType", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_ACTION));
        data.put("eventTime", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_EVENT_TIME));
        data.put("contentChangeTypes", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_CHANGES_TYPES));
        data.put("movementGranularity", intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_MOVEMENT));

        eventSink.success(data);
    }
}
