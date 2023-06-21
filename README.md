# flutter_accessibility_service

a plugin for interacting with Accessibility Service in Android.

Accessibility services are intended to assist users with disabilities in using Android devices and apps, or I can say to get android os events like keyboard key press events or notification received events etc.

for more info check [Accessibility Service](https://developer.android.com/reference/android/accessibilityservice/AccessibilityService)

### Installation and usage

Add package to your pubspec:

```yaml
dependencies:
  flutter_accessibility_service: any # or the latest version on Pub
```

Inside AndroidManifest add this to bind your accessibility service with your application

```xml
    .
    .
    <service android:name="slayer.accessibility.service.flutter_accessibility_service.AccessibilityListener"
                android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" android:exported="false">
      <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
      </intent-filter>
      <meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibilityservice" />
    </service>
    .
    .
</application>

```

Create Accesiblity config file named `accessibilityservice.xml` inside `res/xml` and add the following code inside it:

```xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowsChanged|typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackVisual"
    android:notificationTimeout="300"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRequestTouchExplorationMode|flagRequestEnhancedWebAccessibility|flagReportViewIds|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
>
</accessibility-service>

```

### USAGE

```dart
 /// check if accessibility permission is enebaled
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
     Screen bounds: left: 0 - right: 720 - top: 0 - bottom: 1544 - width: 720 - height: 1544
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

  /// Gets the node bounds in screen coordinates.
  ScreenBounds? screenBounds;

  /// Get the node childrens and sub childrens text
  List<String>? nodesText;
```

### AUTOMATION & ACTIONS

Take a system screenshot

```dart
  /// Take a system screenshot
  await FlutterAccessibilityService.takeScreenShot();
```

Perform actions with `Accessibility Service`

```dart
  /// perform a click action
 final hasBeenClicked = await FlutterAccessibilityService.performAction(
              event.nodeId!,
              NodeAction.actionClick,
            );
          }
```

| Enum Value                            | Description                                                                                                                                                                                                                                | Arguments/Example                                                      |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| `actionAccessibilityFocus`            | Action that gives accessibility focus to the node.                                                                                                                                                                                         |                                                                        |
| `actionClearAccessibilityFocus`       | Action that clears accessibility focus of the node.                                                                                                                                                                                        |                                                                        |
| `actionClearFocus`                    | Action that clears input focus of the node.                                                                                                                                                                                                |                                                                        |
| `actionClearSelection`                | Action that deselects the node.                                                                                                                                                                                                            |                                                                        |
| `actionClick`                         | Action that clicks on the node.                                                                                                                                                                                                            |                                                                        |
| `actionCollapse`                      | Action to collapse an expandable node.                                                                                                                                                                                                     |                                                                        |
| `actionCopy`                          | Action to copy the current selection to the clipboard.                                                                                                                                                                                     |                                                                        |
| `actionCut`                           | Action to cut the current selection and place it to the clipboard.                                                                                                                                                                         |                                                                        |
| `actionDismiss`                       | Action to dismiss a dismissable node.                                                                                                                                                                                                      |                                                                        |
| `actionExpand`                        | Action to expand an expandable node.                                                                                                                                                                                                       |                                                                        |
| `actionFocus`                         | Action that gives input focus to the node.                                                                                                                                                                                                 |                                                                        |
| `actionLongClick`                     | Action that long clicks on the node.                                                                                                                                                                                                       |                                                                        |
| `actionNextAtMovementGranularity`     | Action that requests to go to the next entity in this node's text at a given movement granularity. Pass an argument when you perform an action.                                                                                            | `boolean`                                                              |
| `actionNextHtmlElement`               | Action to move to the next HTML element of a given type. Pass an argument when you perform an action.                                                                                                                                      | `NodeAction.actionNextHtmlElement` with argument `"BUTTON"`            |
| `actionPaste`                         | Action to paste the current clipboard content.                                                                                                                                                                                             |                                                                        |
| `actionPreviousAtMovementGranularity` | Action that requests to go to the previous entity in this node's text at a given movement granularity. Pass an argument when you perform an action.                                                                                        | `NodeAction.actionPreviousAtMovementGranularity` with argument `false` |
| `actionPreviousHtmlElement`           | Action to move to the previous HTML element of a given type. Pass an argument when you perform an action.                                                                                                                                  | `NodeAction.actionPreviousHtmlElement` with argument `"BUTTON"`        |
| `actionScrollBackward`                | Action to scroll the node content backward.                                                                                                                                                                                                |                                                                        |
| `actionScrollForward`                 | Action to scroll the node content forward.                                                                                                                                                                                                 |                                                                        |
| `actionSelect`                        | Action that selects the node.                                                                                                                                                                                                              |                                                                        |
| `actionSetSelection`                  | Action to set the selection. Performing this action with no arguments clears the selection. Pass an argument when you perform an action.                                                                                                   | `NodeAction.actionSetSelection` with argument `{"start": 1, "end": 2}` |
| `actionSetText`                       | Action that sets the text of the node. Performing the action without argument, using null or empty CharSequence will clear the text. This action will also put the cursor at the end of text. Pass an argument when you perform an action. | `NodeAction.actionSetText` with argument `"Flutter"`                   |
| `focusAccessibility`                  | The accessibility focus.                                                                                                                                                                                                                   |                                                                        |
| `focusInput`                          | The input focus.                                                                                                                                                                                                                           |                                                                        |
| `movementGranularityCharacter`        | Movement granularity bit for traversing the text of a node by character.                                                                                                                                                                   |                                                                        |
| `movementGranularityLine`             | Movement granularity bit for traversing the text of a node by line.                                                                                                                                                                        |                                                                        |
| `movementGranularityPage`             | Movement granularity bit for traversing the text of a node by page.                                                                                                                                                                        |                                                                        |
| `movementGranularityParagraph`        | Movement granularity bit for traversing the text of a node by paragraph.                                                                                                                                                                   |                                                                        |
| `movementGranularityWord`             | Movement granularity bit for traversing the text of a node by word.                                                                                                                                                                        |                                                                        |
| `unknown`                             | Unknown action.                                                                                                                                                                                                                            |                                                                        |

For more details about the action check [here](https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo.AccessibilityAction)

#### Accessibility Overlay

This will help to cover the window with an overlay by an accessibility service

Inside main.dart creates an entry point for your Accessibility Overlay widget;

```dart
@pragma("vm:entry-point")
void accessibilityOverlay() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(child: Text("My Accessibility Overlay"))
  ));
}
```

Usage

```dart
/// Show overlay
 await FlutterAccessibilityService.showOverlayWindow();

/// hide overlay
 await FlutterAccessibilityService.hideOverlayWindow();
```

#### Perform Global Actions

Such an action can be performed at any moment regardless of the current application or user location in that application
For example going back, going home, opening recents, etc.

```dart
  await FlutterAccessibilityService.performGlobalAction(
    GlobalAction.globalActionTakeScreenshot,
  );
```

Returns a list of system actions available in the system right now.

```dart
  final list = await FlutterAccessibilityService
      .getSystemActions();
  print(list); // [GlobalAction.globalActionAccessibilityAllApps,GlobalAction.globalActionTakeScreenshot .....]
```
