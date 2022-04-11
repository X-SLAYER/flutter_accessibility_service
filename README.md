# flutter_accessibility_service

a plugin for interacting with Accessibility Service in Android.

Accessibility services are intended to assist users with disabilities in using Android devices and apps, or I can say to get android os events like keyboard key press events or notification received events etc.

for more info check [Accessibility Service](https://developer.android.com/guide/topics/ui/accessibility/)

### Installation and usage ###

Add multiavatar to your pubspec:

```yaml
dependencies:
  flutter_accessibility_service: any # or the latest version on Pub
```

Inside AndroidManifest add this to bind your accessibility service with your application

```
    ...
    <service android:name="slayer.accessibility.service.flutter_accessibility_service.AccessibilityListener" android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibilityservice" />
        </service>
</application>

```

Create Accesiblity config file named `accessibilityservice.xml` inside `res/xml` and add the following code inside it:

```
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes = "typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackVisual"
    android:notificationTimeout="300"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRequestTouchExplorationMode|flagRequestEnhancedWebAccessibility|flagReportViewIds|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
>
</accessibility-service>

```