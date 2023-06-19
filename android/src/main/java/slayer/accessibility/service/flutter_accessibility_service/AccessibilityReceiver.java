package slayer.accessibility.service.flutter_accessibility_service;

import static slayer.accessibility.service.flutter_accessibility_service.Constants.*;

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
        data.put("nodeId", intent.getStringExtra(ACCESSIBILITY_NODE_ID));
        data.put("packageName", intent.getStringExtra(ACCESSIBILITY_NAME));
        data.put("eventType", intent.getIntExtra(ACCESSIBILITY_EVENT_TYPE, -1));
        data.put("capturedText", intent.getStringExtra(ACCESSIBILITY_TEXT));
        data.put("actionType", intent.getIntExtra(ACCESSIBILITY_ACTION, -1));
        data.put("eventTime", intent.getLongExtra(ACCESSIBILITY_EVENT_TIME, -1));
        data.put("contentChangeTypes", intent.getIntExtra(ACCESSIBILITY_CHANGES_TYPES, -1));
        data.put("movementGranularity", intent.getIntExtra(ACCESSIBILITY_MOVEMENT, -1));
        data.put("isActive", intent.getBooleanExtra(ACCESSIBILITY_IS_ACTIVE, false));
        data.put("isFocused", intent.getBooleanExtra(ACCESSIBILITY_IS_FOCUSED, false));
        data.put("isPip", intent.getBooleanExtra(ACCESSIBILITY_IS_PIP, false));
        data.put("windowType", intent.getIntExtra(ACCESSIBILITY_WINDOW_TYPE, -1));
        data.put("screenBounds", intent.getSerializableExtra(ACCESSIBILITY_SCREEN_BOUNDS));
        data.put("nodesText", intent.getStringArrayListExtra(ACCESSIBILITY_NODES_TEXT));
        data.put("parentActions", intent.getIntegerArrayListExtra(ACTION_LIST));
        data.put("subNodesActions", intent.getSerializableExtra(SUB_NODES_ACTIONS));
        eventSink.success(data);
    }
}
