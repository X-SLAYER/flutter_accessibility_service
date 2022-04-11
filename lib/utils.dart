import 'package:flutter_accessibility_service/constants.dart';

class Utils {
  Utils._();

  final Map<int, EventType> eventType = {
    typesAllMask: EventType.typesAllMask,
    typeAnnouncement: EventType.typeAnnouncement,
    typeAssistReadingContext: EventType.typeAssistReadingContext,
    typeGestureDetectionEnd: EventType.typeGestureDetectionEnd,
    typeGestureDetectionStart: EventType.typeGestureDetectionStart,
    typeNotificationStateChanged: EventType.typeNotificationStateChanged,
    typeTouchExplorationGestureEnd: EventType.typeTouchExplorationGestureEnd,
    typeTouchExplorationGestureStart:
        EventType.typeTouchExplorationGestureStart,
    typeTouchInteractionEnd: EventType.typeTouchInteractionEnd,
    typeTouchInteractionStart: EventType.typeTouchInteractionStart,
    typeViewAccessibilityFocused: EventType.typeViewAccessibilityFocused,
    typeViewAccessibilityFocusCleared:
        EventType.typeViewAccessibilityFocusCleared,
    typeViewClicked: EventType.typeViewClicked,
    typeViewContextClicked: EventType.typeViewContextClicked,
    typeViewFocused: EventType.typeViewFocused,
    typeViewHoverEnter: EventType.typeViewHoverEnter,
    typeViewHoverExit: EventType.typeViewHoverExit,
    typeViewLongClicked: EventType.typeViewLongClicked,
    typeViewScrolled: EventType.typeViewScrolled,
    typeViewSelected: EventType.typeViewSelected,
    typeViewTextChanged: EventType.typeViewTextChanged,
    typeViewTextSelectionChanged: EventType.typeViewTextSelectionChanged,
    typeViewTextTraversedAtMovementGranularity:
        EventType.typeViewTextTraversedAtMovementGranularity,
    typeWindowsChanged: EventType.typeWindowsChanged,
    typeWindowContentChanged: EventType.typeWindowContentChanged,
    typeWindowStateChanged: EventType.typeWindowStateChanged,
  };
}
