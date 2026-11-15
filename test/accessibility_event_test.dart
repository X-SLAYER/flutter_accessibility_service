import 'dart:convert';

import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_test/flutter_test.dart';

/// A payload shaped like the Gson JSON that `AccessibilityListener.java`
/// writes to SharedPreferences and the event channel forwards as a String.
const _nativeJson = '''
{
  "mapId": "12_android.widget.Button_OK_null",
  "nodeId": "com.example:id/ok_button",
  "packageName": "com.example",
  "eventType": 32,
  "actionType": 0,
  "eventTime": 123456,
  "movementGranularity": 0,
  "screenBounds": {"left": 10, "right": 110, "top": 20, "bottom": 70, "width": 100, "height": 50},
  "contentChangeTypes": 1,
  "capturedText": "OK",
  "nodesText": ["OK"],
  "parentActions": [16, 64, 777],
  "subNodesActions": [
    {
      "mapId": "child-1",
      "nodeId": "com.example:id/label",
      "capturedText": "Label",
      "screenBounds": {"left": 0, "right": 1, "top": 0, "bottom": 1, "width": 1, "height": 1},
      "isClickable": false,
      "isScrollable": false,
      "isFocusable": true,
      "isCheckable": false,
      "isLongClickable": false,
      "isEditable": false,
      "parentActions": [4],
      "isActive": true,
      "isFocused": false,
      "windowType": 1
    }
  ],
  "isClickable": true,
  "isScrollable": false,
  "isFocusable": true,
  "isCheckable": false,
  "isLongClickable": true,
  "isEditable": false,
  "isActive": true,
  "isFocused": true,
  "windowType": 1,
  "isPip": false
}
''';

void main() {
  group('AccessibilityEvent.fromMap', () {
    late AccessibilityEvent event;

    setUp(() {
      event = AccessibilityEvent.fromMap(jsonDecode(_nativeJson));
    });

    test('parses scalar fields', () {
      expect(event.mapId, '12_android.widget.Button_OK_null');
      expect(event.nodeId, 'com.example:id/ok_button');
      expect(event.packageName, 'com.example');
      expect(event.text, 'OK');
      expect(event.movementGranularity, 0);
    });

    test('parses enums by id', () {
      expect(event.eventType, EventType.typeWindowStateChanged);
      expect(event.windowType, WindowType.typeApplication);
      expect(
        event.contentChangeTypes,
        ContentChangeTypes.contentChangeTypeSubtree,
      );
    });

    test('parses boolean flags', () {
      expect(event.isClickable, isTrue);
      expect(event.isScrollable, isFalse);
      expect(event.isFocusable, isTrue);
      expect(event.isCheckable, isFalse);
      expect(event.isLongClickable, isTrue);
      expect(event.isEditable, isFalse);
      expect(event.isActive, isTrue);
      expect(event.isFocused, isTrue);
      expect(event.isPip, isFalse);
    });

    test('eventTime is set on the Dart side, not from the payload', () {
      final before = DateTime.now();
      final e = AccessibilityEvent.fromMap(jsonDecode(_nativeJson));
      expect(e.eventTime, isNotNull);
      expect(e.eventTime!.isBefore(before), isFalse);
    });

    test('parses screen bounds', () {
      final b = event.screenBounds!;
      expect(
        [b.left, b.right, b.top, b.bottom, b.width, b.height],
        [10, 110, 20, 70, 100, 50],
      );
    });

    test('maps parentActions, unknown ids become NodeAction.unknown', () {
      expect(event.actions, [
        NodeAction.actionClick,
        NodeAction.actionAccessibilityFocus,
        NodeAction.unknown,
      ]);
    });

    test('parses subNodes recursively', () {
      expect(event.subNodes, hasLength(1));
      final child = event.subNodes!.single;
      expect(child.mapId, 'child-1');
      expect(child.nodeId, 'com.example:id/label');
      expect(child.text, 'Label');
      expect(child.isFocusable, isTrue);
      expect(child.windowType, WindowType.typeApplication);
      expect(child.actions, [NodeAction.actionSelect]);
      // Sub-nodes carry no eventType.
      expect(child.eventType, isNull);
      expect(child.subNodes, isEmpty);
    });

    test('unknown actionType falls back to NodeAction.unknown', () {
      // actionType 0 in the payload has no matching NodeAction.
      expect(event.actionType, NodeAction.unknown);
    });

    test('duplicate enum ids resolve to the first declared value', () {
      // NodeAction ids are not unique (actionFocus, focusInput and
      // movementGranularityCharacter are all 1); lookup picks declaration order.
      final e = AccessibilityEvent.fromMap({'actionType': 1});
      expect(e.actionType, NodeAction.actionFocus);
    });

    test('unknown contentChangeTypes id maps to ContentChangeTypes.others', () {
      final e = AccessibilityEvent.fromMap({'contentChangeTypes': 3});
      expect(e.contentChangeTypes, ContentChangeTypes.others);
    });

    test('unknown windowType / eventType ids map to null', () {
      final e = AccessibilityEvent.fromMap({'windowType': 99, 'eventType': 3});
      expect(e.windowType, isNull);
      expect(e.eventType, isNull);
    });

    test('minimal payload yields nulls and empty lists', () {
      final e = AccessibilityEvent.fromMap({});
      expect(e.mapId, isNull);
      expect(e.eventType, isNull);
      expect(e.contentChangeTypes, isNull);
      expect(e.windowType, isNull);
      expect(e.screenBounds, isNull);
      expect(e.movementGranularity, isNull);
      expect(e.actions, isEmpty);
      expect(e.subNodes, isEmpty);
      expect(e.actionType, NodeAction.unknown);
    });

    test('toString does not throw and includes key fields', () {
      final s = event.toString();
      expect(s, contains('com.example'));
      expect(s, contains('subNodes'));
    });
  });

  group('ScreenBounds.fromMap', () {
    test('parses ints and numeric strings', () {
      final b = ScreenBounds.fromMap({
        'left': '1',
        'right': 2,
        'top': 3,
        'bottom': 4,
        'width': 5,
      });
      expect([b.left, b.right, b.top, b.bottom, b.width], [1, 2, 3, 4, 5]);
      expect(b.height, isNull);
    });

    test('toString lists all edges', () {
      final b = ScreenBounds(left: 1, right: 2, top: 3, bottom: 4);
      expect(b.toString(), contains('left: 1'));
      expect(b.toString(), contains('bottom: 4'));
    });
  });
}
