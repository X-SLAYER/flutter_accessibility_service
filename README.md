# flutter_accessibility_service

a plugin for interacting with Accessibility Service in Android.

Accessibility services are intended to assist users with disabilities in using Android devices and apps, or I can say to get android os events like keyboard key press events or notification received events etc.

for more info check [Accessibility Service](https://developer.android.com/reference/android/accessibilityservice/AccessibilityService)

### Installation and usage ###

Add package to your pubspec:

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
    ...
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

### USAGE


```dart
 /// check if accessibility permession is enebaled
 final bool status = await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
 
 /// request accessibility permission
 /// it will open the accessibility settings page and return `true` once the permission granted.
 final bool status = await FlutterAccessibilityService.requestAccessibilityPermission();
 
 /// stream the incoming Accessibility events
  FlutterAccessibilityService.accessStream.listen((event) {
    log("Current Event: $event");
  
  /*
  Current Event: AccessibilityEvent: (
     Action Type: 0 
     Event Time: 2022-04-11 14:19:56.556834 
     Package Name: com.facebook.katana 
     Event Type: EventType.typeWindowContentChanged 
     Captured Text: events you may like 
     content Change Types: ContentChangeTypes.contentChangeTypeSubtree 
     Movement Granularity: 0
     Is Active: true
     is focused: true
     in Pip: false
     window Type: WindowType.typeApplication
)
  */
  
  });
```

The `AccessibilityEvent` provides:

```dart
  /// the performed action that triggered this event
  int? actionType;
  
  /// the time in which this event was sent.
  DateTime? eventTime;
  
  /// the package name of the source
  String? packageName;
  
  /// the event type.
  EventType? eventType;
  
  /// Gets the text of this node.
  String? capturedText;
  
  /// the bit mask of change types signaled by a `TYPE_WINDOW_CONTENT_CHANGED` event or `TYPE_WINDOW_STATE_CHANGED`. A single event may represent multiple change types
  ContentChangeTypes? contentChangeTypes;
  
  /// the movement granularity that was traversed
  int? movementGranularity;
  
  /// the type of the window
  WindowType? windowType;
  
  /// check if this window is active. An active window is the one the user is currently touching or the window has input focus and the user is not touching any window.
  bool? isActive;
  
  /// check if this window has input focus.
  bool? isFocused;
  
  /// Check if the window is in picture-in-picture mode.
  bool? isPip;
```

for each event.
