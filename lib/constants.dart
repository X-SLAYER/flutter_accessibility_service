enum EventType {
  typesAllMask(-1),
  typeAnnouncement(16384),
  typeAssistReadingContext(16777216),
  typeGestureDetectionEnd(524288),
  typeGestureDetectionStart(262144),
  typeNotificationStateChanged(64),
  typeTouchExplorationGestureEnd(1024),
  typeTouchExplorationGestureStart(512),
  typeTouchInteractionEnd(2097152),
  typeTouchInteractionStart(1048576),
  typeViewAccessibilityFocused(32768),
  typeViewAccessibilityFocusCleared(65536),
  typeViewClicked(1),
  typeViewContextClicked(8388608),
  typeViewFocused(8),
  typeViewHoverEnter(128),
  typeViewHoverExit(256),
  typeViewLongClicked(2),
  typeViewScrolled(4096),
  typeViewSelected(4),
  typeViewTextChanged(16),
  typeViewTextSelectionChanged(8192),
  typeViewTextTraversedAtMovementGranularity(131072),
  typeWindowsChanged(4194304),
  typeWindowContentChanged(2048),
  typeWindowStateChanged(32);

  final int id;

  const EventType(this.id);
}

enum ContentChangeTypes {
  contentChangeTypeContentDescription(4),
  contentChangeTypePaneAppeared(16),
  contentChangeTypePaneDisappeared(32),
  contentChangeTypePaneTitle(8),
  contentChangeTypeStateDescription(64),
  contentChangeTypeSubtree(1),
  contentChangeTypeText(2),
  contentChangeTypeUndefined(0),
  others(null);

  final int? id;

  const ContentChangeTypes(this.id);
}

enum WindowType {
  typeAccessibilityOverlay(4),
  typeApplication(1),
  typeInputMethod(2),
  typeSplitScreenDivider(5),
  typeSystem(3);

  final int id;

  const WindowType(this.id);
}

enum NodeAction {
  /// Action that gives accessibility focus to the node.
  actionAccessibilityFocus(64),

  /// Action that clears accessibility focus of the node.
  actionClearAccessibilityFocus(128),

  /// Action that clears input focus of the node.
  actionClearFocus(2),

  /// Action that deselects the node.
  actionClearSelection(8),

  /// Action that clicks on the node info. see:
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo.AccessibilityAction#ACTION_CLICK
  actionClick(16),

  /// Action to collapse an expandable node.
  actionCollapse(524288),

  /// Action to copy the current selection to the clipboard.
  actionCopy(16384),

  /// Action to cut the current selection and place it to the clipboard.
  actionCut(65536),

  /// Action to dismiss a dismissable node.
  actionDismiss(1048576),

  /// Action to expand an expandable node.
  actionExpand(262144),

  /// Action that gives input focus to the node.
  actionFocus(1),

  /// Action that long clicks on the node.
  actionLongClick(32),

  /// Action that requests to go to the next entity in this node's text at a given movement granularity.
  /// For example, move to the next character, word, etc.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionNextAtMovementGranularity,
  ///     false,
  ///  );
  /// ```
  actionNextAtMovementGranularity(256),

  /// Action to move to the next HTML element of a given type. For example, move to the BUTTON, INPUT, TABLE, etc.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionNextHtmlElement,
  ///     "BUTTON",
  ///  );
  /// ```
  actionNextHtmlElement(1024),

  /// Action to paste the current clipboard content.
  actionPaste(32768),

  /// Action that requests to go to the previous entity in this node's text at a given movement granularity.
  /// For example, move to the next character, word, etc.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionPreviousAtMovementGranularity,
  ///     false,
  ///  );
  /// ```
  actionPreviousAtMovementGranularity(512),

  /// Action to move to the previous HTML element of a given type. For example, move to the BUTTON, INPUT, TABLE, etc.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionPreviousHtmlElement,
  ///     "BUTTON",
  ///  );
  /// ```
  actionPreviousHtmlElement(2048),

  /// Action to scroll the node content backward.
  actionScrollBackward(8192),

  /// Action to scroll the node content forward.
  actionScrollForward(4096),

  /// Action that selects the node.
  actionSelect(4),

  /// Action to set the selection. Performing this action with no arguments clears the selection.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionSetSelection,
  ///     {"start": 1, "end": 2},
  ///  );
  /// ```
  actionSetSelection(131072),

  /// Action that sets the text of the node. Performing the action without argument, using null or empty CharSequence will clear the text.
  /// This action will also put the cursor at the end of text.
  /// pass an argument when you perform an action
  ///
  /// example:
  ///
  /// ```dart
  ///   final status = await FlutterAccessibilityService.performAction(
  ///     frame.nodeId!,
  ///     NodeAction.actionSetText,
  ///     "Flutter",
  ///  );
  /// ```
  actionSetText(2097152),

  /// The accessibility focus.
  focusAccessibility(2),

  /// The input focus.
  focusInput(1),

  /// Movement granularity bit for traversing the text of a node by character.
  movementGranularityCharacter(1),

  /// Movement granularity bit for traversing the text of a node by line.
  movementGranularityLine(4),

  /// Movement granularity bit for traversing the text of a node by page.
  movementGranularityPage(16),

  /// Movement granularity bit for traversing the text of a node by paragraph.
  movementGranularityParagraph(8),

  /// Movement granularity bit for traversing the text of a node by word.
  movementGranularityWord(2),

  /// Unknown action
  unknown(null);

  final int? id;

  const NodeAction(this.id);
}

enum GlobalAction {
  /// Action to show Launcher's all apps.
  globalActionAccessibilityAllApps(14),

  /// Action to trigger the Accessibility Button.
  globalActionAccessibilityButton(11),

  /// Action to bring up the Accessibility Button's chooser menu.
  globalActionAccessibilityButtonChooser(12),

  ///Action to trigger the Accessibility Shortcut.
  /// This shortcut has a hardware trigger and can be activated by holding down the two volume keys.
  globalActionAccessibilityShortcut(13),

  /// ction to go back.
  globalActionBack(1),

  /// Action to dismiss the notification shade.
  globalActionDismissNotificationShade(15),

  /// Action to go home.
  globalActionHome(2),

  /// Action to send the KEYCODE_HEADSETHOOK KeyEvent, which is used to answer/hang up calls and play/stop media.
  globalActionKeycodeHeadsethook(10),

  /// Action to lock the screen.
  globalActionLockScreen(8),

  /// Action to open the notifications.
  globalActionNotifications(4),

  /// Action to open the power long-press dialog.
  globalActionPowerDialog(6),

  /// Action to open the quick settings.
  globalActionQuickSettings(5),

  /// Action to toggle showing the overview of recent apps.
  /// Will fail on platforms that don't show recent apps.
  globalActionRecents(3),

  /// Action to toggle docking the current app's window.
  globalActionTakeScreenshot(9),

  /// Action to toggle docking the current app's window.
  globalActionToggleSplitScreen(7),

  /// Unknown Global action
  unknown(null);

  final int? id;

  const GlobalAction(this.id);
}
