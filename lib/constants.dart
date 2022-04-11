enum EventType {
  typesAllMask,
  typeAnnouncement,
  typeAssistReadingContext,
  typeGestureDetectionEnd,
  typeGestureDetectionStart,
  typeNotificationStateChanged,
  typeTouchExplorationGestureEnd,
  typeTouchExplorationGestureStart,
  typeTouchInteractionEnd,
  typeTouchInteractionStart,
  typeViewAccessibilityFocused,
  typeViewAccessibilityFocusCleared,
  typeViewClicked,
  typeViewContextClicked,
  typeViewFocused,
  typeViewHoverEnter,
  typeViewHoverExit,
  typeViewLongClicked,
  typeViewScrolled,
  typeViewSelected,
  typeViewTextChanged,
  typeViewTextSelectionChanged,
  typeViewTextTraversedAtMovementGranularity,
  typeWindowsChanged,
  typeWindowContentChanged,
  typeWindowStateChanged,
}

enum ContentChangeTypes {
  contentChangeTypeContentDescription,
  contentChangeTypePaneAppeared,
  contentChangeTypePaneDisappeared,
  contentChangeTypePaneTitle,
  contentChangeTypeStateDescription,
  contentChangeTypeSubtree,
  contentChangeTypeText,
  contentChangeTypeUndefined,
  others,
}

enum WindowType {
  typeAccessibilityOverlay,
  typeApplication,
  typeInputMethod,
  typeSplitScreenDivider,
  typeSystem,
}

const int typesAllMask = -1;
const int typeAnnouncement = 16384;
const int typeAssistReadingContext = 16777216;
const int typeGestureDetectionEnd = 524288;
const int typeGestureDetectionStart = 262144;
const int typeNotificationStateChanged = 64;
const int typeTouchExplorationGestureEnd = 1024;
const int typeTouchExplorationGestureStart = 512;
const int typeTouchInteractionEnd = 2097152;
const int typeTouchInteractionStart = 1048576;
const int typeViewAccessibilityFocused = 32768;
const int typeViewAccessibilityFocusCleared = 65536;
const int typeViewClicked = 1;
const int typeViewContextClicked = 8388608;
const int typeViewFocused = 8;
const int typeViewHoverEnter = 128;
const int typeViewHoverExit = 256;
const int typeViewLongClicked = 2;
const int typeViewScrolled = 4096;
const int typeViewSelected = 4;
const int typeViewTextChanged = 16;
const int typeViewTextSelectionChanged = 8192;
const int typeViewTextTraversedAtMovementGranularity = 131072;
const int typeWindowsChanged = 4194304;
const int typeWindowContentChanged = 2048;
const int typeWindowStateChanged = 32;
// --------
const int contentChangeTypeContentDescription = 4;
const int contentChangeTypePaneAppeared = 16;
const int contentChangeTypePaneDisappeared = 32;
const int contentChangeTypePaneTitle = 8;
const int contentChangeTypeStateDescription = 64;
const int contentChangeTypeSubtree = 1;
const int contentChangeTypeText = 2;
const int contentChangeTypeUndefined = 0;
// --------
const int typeAccessibilityOverlay = 4;
const int typeApplication = 1;
const int typeInputMethod = 2;
const int typeSplitScreenDivider = 5;
const int typeSystem = 3;
