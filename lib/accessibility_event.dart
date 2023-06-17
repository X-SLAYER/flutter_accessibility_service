import 'package:collection/collection.dart';

import 'constants.dart';

class AccessibilityEvent {
  /// Gets the fully qualified resource name of the source view's id.
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getViewIdResourceName()
  String? nodeId;

  /// The performed action that triggered this event
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityEvent#getAction()
  NodeAction? actionType;

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

  /// Get the node childrens and sub childrens text
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getChild(int)
  List<String>? nodesText;

  /// Get the node childrens available actions
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getViewIdResourceName()
  List<NodeAction>? actions;

  /// Get sub childrens view's id and available actions
  /// https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo#getViewIdResourceName()
  List<SubNodes>? subNodes;

  AccessibilityEvent({
    this.nodeId,
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
    this.nodesText,
    this.actions,
  });

  AccessibilityEvent.fromMap(Map<dynamic, dynamic> map) {
    nodeId = map['nodeId'];
    actionType = NodeAction.values
            .firstWhereOrNull((element) => element.id == map['actionType']) ??
        NodeAction.unknown;
    eventTime = DateTime.now();
    packageName = map['packageName'];
    if (map['eventType'] == null) {
      eventType = null;
    } else {
      eventType = EventType.values
          .firstWhereOrNull((element) => element.id == map['eventType']);
    }
    capturedText = map['capturedText'];
    contentChangeTypes = map['contentChangeTypes'] == null
        ? null
        : (ContentChangeTypes.values.firstWhereOrNull(
                (element) => element.id == map['contentChangeTypes']) ??
            ContentChangeTypes.others);
    movementGranularity = map['movementGranularity'];
    windowType = map['windowType'] == null
        ? null
        : WindowType.values
            .firstWhereOrNull((element) => element.id == map['windowType']);
    isActive = map['isActive'];
    isFocused = map['isFocused'];
    isPip = map['isPip'];
    screenBounds = map['screenBounds'] != null
        ? ScreenBounds.fromMap(map['screenBounds'])
        : null;
    subNodes = map['subNodesActions'] != null
        ? (map['subNodesActions'] as Map<dynamic, dynamic>)
            .keys
            .map(
              (key) => SubNodes(
                text: map['subNodesActions'][key]['text'],
                nodeId: key,
                actions: ((map['subNodesActions'][key]['actions'])
                        as List<dynamic>)
                    .map((e) =>
                        (NodeAction.values
                            .firstWhereOrNull((element) => element.id == e)) ??
                        NodeAction.unknown)
                    .toList(),
              ),
            )
            .toList()
        : null;
    nodesText = map['nodesText'] == null
        ? []
        : [
            ...{...map['nodesText']}
          ];
    actions = map['parentActions'] == null
        ? []
        : (map['parentActions'] as List<dynamic>)
            .map((e) =>
                (NodeAction.values
                    .firstWhereOrNull((element) => element.id == e)) ??
                NodeAction.unknown)
            .toList();
  }

  @override
  String toString() {
    return '''AccessibilityEvent: (
       nodeId: $nodeId 
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
       Nodes Text: $nodesText
       actions: $actions
       subNodes: $subNodes
       )''';
  }
}

class ScreenBounds {
  int? right;
  int? top;
  int? left;
  int? bottom;
  int? width;
  int? height;

  ScreenBounds({
    this.right,
    this.top,
    this.left,
    this.bottom,
    this.width,
    this.height,
  });

  ScreenBounds.fromMap(Map<dynamic, dynamic> json) {
    right = json['right'];
    top = json['top'];
    left = json['left'];
    bottom = json['bottom'];
    width = json['width'];
    height = json['height'];
  }

  @override
  String toString() {
    return "left: $left - right: $right - top: $top - bottom: $bottom - width: $width - height: $height";
  }
}

class SubNodes {
  String? nodeId;
  String? text;
  List<NodeAction>? actions;

  SubNodes({
    this.nodeId,
    this.actions,
    this.text,
  });

  @override
  String toString() {
    return ''' SubNodes(
    nodeId: $nodeId 
    Text: $text 
    Actions: $actions
    )
    ''';
  }
}
