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
