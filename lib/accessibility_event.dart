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
  int? contentChangeTypes;

  /// the movement granularity that was traversed
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getMovementGranularity()
  int? movementGranularity;

  AccessibilityEvent({
    this.actionType,
    this.eventTime,
    this.packageName,
    this.eventType,
    this.capturedText,
    this.contentChangeTypes,
    this.movementGranularity,
  });

  AccessibilityEvent.fromMap(Map<dynamic, dynamic> map) {
    actionType = map['actionType'];
    eventTime = DateTime.now();
    packageName = map['packageName'];
    eventType =
        map['eventType'] == null ? null : Utils.eventType[map['eventType']];
    capturedText = map['capturedText'];
    contentChangeTypes = map['contentChangeTypes'];
    movementGranularity = map['movementGranularity'];
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
    )''';
  }
}
