package slayer.accessibility.service.flutter_accessibility_service;

import static android.content.Context.MODE_PRIVATE;
import static slayer.accessibility.service.flutter_accessibility_service.Constants.*;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;

public class AccessibilityReceiver extends BroadcastReceiver {

    private volatile EventChannel.EventSink eventSink;

    public AccessibilityReceiver(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    public void setEventSink(EventChannel.EventSink sink) {
        this.eventSink = sink;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        EventChannel.EventSink sink = eventSink;
        if (sink == null) return;
        SharedPreferences sharedPreferences = context.getSharedPreferences(SHARED_PREFS_TAG, MODE_PRIVATE);
        String json = sharedPreferences.getString(ACCESSIBILITY_NODE, "");
        try {
            sink.success(json);
        } catch (Exception e) {
            Log.w("AccessibilityReceiver", "Failed to deliver event, engine may be detached: " + e.getMessage());
        }
    }
}
