package slayer.accessibility.service.flutter_accessibility_service;

import android.content.Context;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;
import android.view.accessibility.AccessibilityNodeInfo;

import androidx.annotation.RequiresApi;

public class Utils {

    public static boolean isAccessibilitySettingsOn(Context mContext) {
        int accessibilityEnabled = 0;
        final String service = mContext.getPackageName() + "/" + AccessibilityListener.class.getCanonicalName();
        try {
            accessibilityEnabled = Settings.Secure.getInt(
                    mContext.getApplicationContext().getContentResolver(),
                    android.provider.Settings.Secure.ACCESSIBILITY_ENABLED);
        } catch (Settings.SettingNotFoundException e) {
        }
        TextUtils.SimpleStringSplitter mStringColonSplitter = new TextUtils.SimpleStringSplitter(':');
        if (accessibilityEnabled == 1) {
            String settingValue = Settings.Secure.getString(
                    mContext.getApplicationContext().getContentResolver(),
                    Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
            if (settingValue != null) {
                mStringColonSplitter.setString(settingValue);
                while (mStringColonSplitter.hasNext()) {
                    String accessibilityService = mStringColonSplitter.next();
                    if (accessibilityService.equalsIgnoreCase(service)) {
                        return true;
                    }
                }
            }
        } else {
        }
        return false;
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR2)
    static AccessibilityNodeInfo findNode(AccessibilityNodeInfo nodeInfo, String nodeId) {
        if (nodeInfo.getViewIdResourceName() != null && nodeInfo.getViewIdResourceName().equals(nodeId)) {
            return nodeInfo;
        }
        for (int i = 0; i < nodeInfo.getChildCount(); i++) {
            AccessibilityNodeInfo child = nodeInfo.getChild(i);
            AccessibilityNodeInfo result = findNode(child, nodeId);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
}
