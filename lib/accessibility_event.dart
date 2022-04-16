import 'package:flutter_accessibility_service/utils.dart';

import 'constants.dart';

class AccessibilityEvent {
  /// the performed action that triggered this event
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getAction()
  int? actionType;

  /// the time in which this event was sent.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#TYPE_WINDOW_CONTENT_CHANGED
  DateTime? eventTime;

  /// the package name of the source
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getPackageName()
  String? packageName;

  /// the event type.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getEventTime()
  EventType? eventType;

  /// Gets the text of this node.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getText()
  String? capturedText;

  /// the bit mask of change types signaled by a `TYPE_WINDOW_CONTENT_CHANGED` event or `TYPE_WINDOW_STATE_CHANGED`. A single event may represent multiple change types
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getContentChangeTypes()
  ContentChangeTypes? contentChangeTypes;

  /// the movement granularity that was traversed
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getMovementGranularity()
  int? movementGranularity;

  /// the type of the window
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityWindowInfo#getType()
  WindowType? windowType;

  /// check if this window is active. An active window is the one the user is currently touching or the window has input focus and the user is not touching any window.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityWindowInfo#getType()
  bool? isActive;

  /// check if this window has input focus.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityWindowInfo#isFocused()
  bool? isFocused;

  /// Check if the window is in picture-in-picture mode.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityWindowInfo#isInPictureInPictureMode()
  bool? isPip;

  /// Gets the node bounds in screen coordinates.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getBoundsInScreen(android.graphics.Rect)
  ScreenBounds? screenBounds;

  AccessibilityEvent({
    this.actionType,
    this.eventTime,
    this.packageName,
    this.eventType,
    this.capturedText,
    this.contentChangeTypes,
    this.movementGranularity,
    this.windowType,
    this.isActive,
    this.isFocused,
    this.isPip,
    this.screenBounds,
  });

  AccessibilityEvent.fromMap(Map<dynamic, dynamic> map) {
    actionType = map['actionType'];
    eventTime = DateTime.now();
    packageName = map['packageName'];
    eventType =
        map['eventType'] == null ? null : Utils.eventType[map['eventType']];
    capturedText = map['capturedText'];
    contentChangeTypes = map['contentChangeTypes'] == null
        ? null
        : (Utils.changeType[map['contentChangeTypes']] ??
            ContentChangeTypes.others);
    movementGranularity = map['movementGranularity'];
    windowType =
        map['windowType'] == null ? null : Utils.windowType[map['windowType']];
    isActive = map['isActive'];
    isFocused = map['isFocused'];
    isPip = map['isPip'];
    screenBounds = map['screenBounds'] != null
        ? ScreenBounds.fromMap(map['screenBounds'])
        : null;
  }

  @override
  String toString() {
    return '''AccessibilityEvent: (
       Action Type: $actionType 
       Event Time: $eventTime 
       Package Name: $packageName 
       Event Type: $eventType 
       Captured Text: $capturedText 
       content Change Types: $contentChangeTypes 
       Movement Granularity: $movementGranularity
       Is Active: $isActive
       is focused: $isFocused
       in Pip: $isPip
       window Type: $windowType
       Screen bounds: $screenBounds
       )''';
  }
}

class ScreenBounds {
  int? right;
  int? top;
  int? left;
  int? bottom;

  ScreenBounds({
    this.right,
    this.top,
    this.left,
    this.bottom,
  });

  ScreenBounds.fromMap(Map<dynamic, dynamic> json) {
    right = json['right'];
    top = json['top'];
    left = json['left'];
    bottom = json['bottom'];
  }

  @override
  String toString() {
    return "left: $left - right: $right - top: $top - bottom: $bottom";
  }
}
