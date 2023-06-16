package slayer.accessibility.service.flutter_accessibility_service;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.provider.Settings;
import android.util.Log;
import android.view.accessibility.AccessibilityNodeInfo;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FlutterAccessibilityServicePlugin
 */
public class FlutterAccessibilityServicePlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.ActivityResultListener, EventChannel.StreamHandler {

    private static final String CHANNEL_TAG = "x-slayer/accessibility_channel";
    private static final String EVENT_TAG = "x-slayer/accessibility_event";

    private MethodChannel channel;
    private AccessibilityReceiver accessibilityReceiver;
    private EventChannel eventChannel;
    private Context context;
    private Activity mActivity;

    private Result pendingResult;
    final int REQUEST_CODE_FOR_ACCESSIBILITY = 167;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_TAG);
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_TAG);
        eventChannel.setStreamHandler(this);

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        pendingResult = result;
        if (call.method.equals("isAccessibilityPermissionEnabled")) {
            result.success(Utils.isAccessibilitySettingsOn(context));
        } else if (call.method.equals("requestAccessibilityPermission")) {
            Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
            mActivity.startActivityForResult(intent, REQUEST_CODE_FOR_ACCESSIBILITY);
        } else if (call.method.equals("takeScreenShot")) {
            if (Utils.isAccessibilitySettingsOn(context)) {
                final Intent i = new Intent(context, AccessibilityListener.class);
                i.putExtra(AccessibilityListener.INTENT_TAKE_SCREENSHOT, true);
                context.startService(i);
                result.success(true);
            }
            result.success(false);
        } else if (call.method.equals("performClick")) {
            String nodeId = call.argument("nodeId");
            AccessibilityNodeInfo nodeInfo = AccessibilityListener.getNodeInfo();
            if (nodeInfo != null) {
                AccessibilityNodeInfo nodeToClick = null;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
                    nodeToClick = Utils.findNode(nodeInfo, nodeId);
                }
                if (nodeToClick != null) {
                    nodeToClick.performAction(AccessibilityNodeInfo.ACTION_CLICK);
                    result.success(true);
                } else {
                    result.success(false);
                }
            } else {
                result.success(false);
            }

        } else {
            result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        if (Utils.isAccessibilitySettingsOn(context)) {
            /// Set up receiver
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(AccessibilityListener.ACCESSIBILITY_INTENT);

            accessibilityReceiver = new AccessibilityReceiver(events);
            context.registerReceiver(accessibilityReceiver, intentFilter);

            /// Set up listener intent
            Intent listenerIntent = new Intent(context, AccessibilityListener.class);
            context.startService(listenerIntent);
            Log.i("AccessibilityPlugin", "Started the accessibility tracking service.");
        }
    }

    @Override
    public void onCancel(Object arguments) {
        context.unregisterReceiver(accessibilityReceiver);
        accessibilityReceiver = null;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FOR_ACCESSIBILITY) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult.success(true);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                pendingResult.success(Utils.isAccessibilitySettingsOn(context));
            } else {
                pendingResult.success(false);
            }
            return true;
        }
        return false;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.mActivity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        this.mActivity = null;
    }
}
