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
        /// Unpack intent contents
        String packageName = intent.getStringExtra(AccessibilityListener.ACCESSIBILITY_NAME);

        /// Send data back via the Event Sink
        HashMap<String, Object> data = new HashMap<>();
        data.put("packageName", packageName);
        eventSink.success(data);
    }
}
