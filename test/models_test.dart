import 'package:flutter_accessibility_service/config/overlay_config.dart';
import 'package:flutter_accessibility_service/config/overlay_gravity.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/gesture_description.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayGravity', () {
    // Values must match android.view.Gravity constants.
    test('maps to Android Gravity values', () {
      expect(
        {for (final g in OverlayGravity.values) g: g.value},
        {
          OverlayGravity.top: 48,
          OverlayGravity.bottom: 80,
          OverlayGravity.left: 3,
          OverlayGravity.right: 5,
          OverlayGravity.topLeft: 48 | 3,
          OverlayGravity.topRight: 48 | 5,
          OverlayGravity.bottomLeft: 80 | 3,
          OverlayGravity.bottomRight: 80 | 5,
        },
      );
    });
  });

  group('OverlayConfig', () {
    test('defaults', () {
      const c = OverlayConfig();
      expect(c.clickableThrough, isFalse);
      expect(c.width, -1);
      expect(c.height, -1);
      expect(c.gravity, OverlayGravity.top);
    });

    test('toJson uses keys read by the Java plugin', () {
      const c = OverlayConfig(
        clickableThrough: true,
        width: 10,
        height: 20,
        gravity: OverlayGravity.left,
      );
      expect(c.toJson(), {
        'clickableThrough': true,
        'width': 10,
        'height': 20,
        'gravity': 3,
      });
    });

    test('copyWith overrides only given fields', () {
      const base = OverlayConfig(width: 100, height: 200);
      final c = base.copyWith(gravity: OverlayGravity.bottom);
      expect(c.width, 100);
      expect(c.height, 200);
      expect(c.clickableThrough, isFalse);
      expect(c.gravity, OverlayGravity.bottom);
    });
  });

  group('Gesture models', () {
    test('GesturePoint.toJson', () {
      expect(const GesturePoint(1.5, 2).toJson(), {'x': 1.5, 'y': 2.0});
    });

    test('GestureStroke defaults', () {
      const s = GestureStroke(path: [GesturePoint(0, 0)]);
      expect(s.startTime, 0);
      expect(s.duration, 100);
    });

    test('GestureStroke.toJson', () {
      const s = GestureStroke(
        path: [GesturePoint(1, 2), GesturePoint(3, 4)],
        startTime: 50,
        duration: 300,
      );
      expect(s.toJson(), {
        'path': [
          {'x': 1.0, 'y': 2.0},
          {'x': 3.0, 'y': 4.0},
        ],
        'startTime': 50,
        'duration': 300,
      });
    });

    test('GestureDescription.toJson serializes every stroke in order', () {
      const g = GestureDescription(
        strokes: [
          GestureStroke(path: [GesturePoint(0, 0)]),
          GestureStroke(path: [GesturePoint(9, 9)], startTime: 200),
        ],
      );
      final json = g.toJson();
      expect(json, hasLength(2));
      expect(json[0]['path'], [
        {'x': 0.0, 'y': 0.0},
      ]);
      expect(json[1]['startTime'], 200);
    });
  });

  group('Enum ids', () {
    // Guards against copy/paste mistakes when adding values: these enums are
    // looked up by id, so a duplicate would silently shadow a value.
    void expectUniqueIds(String name, Iterable<int?> ids) {
      final nonNull = ids.whereType<int>().toList();
      expect(
        nonNull.toSet().length,
        nonNull.length,
        reason: '$name has duplicate ids',
      );
    }

    test('EventType ids are unique', () {
      expectUniqueIds('EventType', EventType.values.map((e) => e.id));
    });

    test('WindowType ids are unique', () {
      expectUniqueIds('WindowType', WindowType.values.map((e) => e.id));
    });

    test('ContentChangeTypes ids are unique', () {
      expectUniqueIds(
        'ContentChangeTypes',
        ContentChangeTypes.values.map((e) => e.id),
      );
    });

    test('GlobalAction ids are unique', () {
      expectUniqueIds('GlobalAction', GlobalAction.values.map((e) => e.id));
    });

    test('NodeAction "action*" ids are unique', () {
      // focus*/movementGranularity* are flag constants, not actions, and
      // intentionally overlap with action ids.
      expectUniqueIds(
        'NodeAction',
        NodeAction.values
            .where((a) => a.name.startsWith('action'))
            .map((a) => a.id),
      );
    });

    test('sentinel values have null ids', () {
      expect(NodeAction.unknown.id, isNull);
      expect(GlobalAction.unknown.id, isNull);
      expect(ContentChangeTypes.others.id, isNull);
    });

    test('spot-check ids against Android constants', () {
      expect(NodeAction.actionClick.id, 16);
      expect(NodeAction.actionSetText.id, 2097152);
      expect(GlobalAction.globalActionBack.id, 1);
      expect(GlobalAction.globalActionTakeScreenshot.id, 9);
      expect(EventType.typeWindowContentChanged.id, 2048);
      expect(EventType.typeWindowStateChanged.id, 32);
    });
  });
}
