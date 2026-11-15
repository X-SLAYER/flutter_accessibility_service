import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/config/overlay_config.dart';
import 'package:flutter_accessibility_service/config/overlay_gravity.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/gesture_description.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('x-slayer/accessibility_channel');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final log = <MethodCall>[];

  /// Installs a mock native side. [responses] maps method name -> return
  /// value; unknown methods return null.
  void mockNative(Map<String, Object?> responses) {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      log.add(call);
      return responses[call.method];
    });
  }

  /// Installs a mock native side that throws [PlatformException] for every call.
  void mockNativeThrows() {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      log.add(call);
      throw PlatformException(code: 'ERR', message: 'native failure');
    });
  }

  tearDown(() {
    log.clear();
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  group('requestAccessibilityPermission', () {
    test('returns native result', () async {
      mockNative({'requestAccessibilityPermission': true});
      expect(
        await FlutterAccessibilityService.requestAccessibilityPermission(),
        isTrue,
      );
      expect(log, [
        isMethodCall('requestAccessibilityPermission', arguments: null),
      ]);
    });

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(
        await FlutterAccessibilityService.requestAccessibilityPermission(),
        isFalse,
      );
    });
  });

  group('isAccessibilityPermissionEnabled', () {
    test('returns native result', () async {
      mockNative({'isAccessibilityPermissionEnabled': false});
      expect(
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled(),
        isFalse,
      );
      expect(log, [
        isMethodCall('isAccessibilityPermissionEnabled', arguments: null),
      ]);
    });

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled(),
        isFalse,
      );
    });
  });

  group('performAction', () {
    final event = AccessibilityEvent(mapId: 'node-42');

    test('sends mapId, action id and extras', () async {
      mockNative({'performActionById': true});
      final result = await FlutterAccessibilityService.performAction(
        event,
        NodeAction.actionSetText,
        'Flutter',
      );
      expect(result, isTrue);
      expect(log, [
        isMethodCall(
          'performActionById',
          arguments: {
            'nodeId': 'node-42',
            'nodeAction': 2097152,
            'extras': 'Flutter',
          },
        ),
      ]);
    });

    test('sends null extras when no argument is given', () async {
      mockNative({'performActionById': true});
      await FlutterAccessibilityService.performAction(
        event,
        NodeAction.actionClick,
      );
      expect(log, [
        isMethodCall(
          'performActionById',
          arguments: {'nodeId': 'node-42', 'nodeAction': 16, 'extras': null},
        ),
      ]);
    });

    test('passes map extras through for actionSetSelection', () async {
      mockNative({'performActionById': true});
      await FlutterAccessibilityService.performAction(
        event,
        NodeAction.actionSetSelection,
        {'start': 1, 'end': 2},
      );
      expect((log.single.arguments as Map)['extras'], {'start': 1, 'end': 2});
    });

    test('short-circuits NodeAction.unknown without calling native', () async {
      mockNative({'performActionById': true});
      expect(
        await FlutterAccessibilityService.performAction(
          event,
          NodeAction.unknown,
        ),
        isFalse,
      );
      expect(log, isEmpty);
    });

    test('returns false when native returns null (node not found)', () async {
      mockNative({'performActionById': null});
      expect(
        await FlutterAccessibilityService.performAction(
          event,
          NodeAction.actionClick,
        ),
        isFalse,
      );
    });

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(
        await FlutterAccessibilityService.performAction(
          event,
          NodeAction.actionClick,
        ),
        isFalse,
      );
    });
  });

  group('showOverlayWindow', () {
    test('sends default OverlayConfig', () async {
      mockNative({'showOverlayWindow': true});
      expect(await FlutterAccessibilityService.showOverlayWindow(), isTrue);
      expect(log, [
        isMethodCall(
          'showOverlayWindow',
          arguments: {
            'clickableThrough': false,
            'width': -1,
            'height': -1,
            'gravity': 48,
          },
        ),
      ]);
    });

    test('sends custom OverlayConfig', () async {
      mockNative({'showOverlayWindow': true});
      await FlutterAccessibilityService.showOverlayWindow(
        const OverlayConfig(
          clickableThrough: true,
          width: 300,
          height: 200,
          gravity: OverlayGravity.bottomRight,
        ),
      );
      expect(log, [
        isMethodCall(
          'showOverlayWindow',
          arguments: {
            'clickableThrough': true,
            'width': 300,
            'height': 200,
            'gravity': 85,
          },
        ),
      ]);
    });

    test('returns false when overlay entry point is missing', () async {
      // Native responds with ERR:OVERLAY when `accessibilityOverlay` is absent.
      messenger.setMockMethodCallHandler(methodChannel, (call) async {
        throw PlatformException(code: 'ERR:OVERLAY');
      });
      expect(await FlutterAccessibilityService.showOverlayWindow(), isFalse);
    });

    test('returns false when native returns null', () async {
      mockNative({});
      expect(await FlutterAccessibilityService.showOverlayWindow(), isFalse);
    });
  });

  group('hideOverlayWindow', () {
    test('returns native result', () async {
      mockNative({'hideOverlayWindow': true});
      expect(await FlutterAccessibilityService.hideOverlayWindow(), isTrue);
      expect(log, [isMethodCall('hideOverlayWindow', arguments: null)]);
    });

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(await FlutterAccessibilityService.hideOverlayWindow(), isFalse);
    });
  });

  group('getSystemActions', () {
    test(
      'maps ids to GlobalAction, unknown ids to GlobalAction.unknown',
      () async {
        mockNative({
          'getSystemActions': [1, 2, 3, 9999],
        });
        expect(await FlutterAccessibilityService.getSystemActions(), [
          GlobalAction.globalActionBack,
          GlobalAction.globalActionHome,
          GlobalAction.globalActionRecents,
          GlobalAction.unknown,
        ]);
        expect(log, [isMethodCall('getSystemActions', arguments: null)]);
      },
    );

    test('returns empty list when native returns null', () async {
      mockNative({});
      expect(await FlutterAccessibilityService.getSystemActions(), isEmpty);
    });

    test(
      'returns empty list on PlatformException (service disabled)',
      () async {
        mockNativeThrows();
        expect(await FlutterAccessibilityService.getSystemActions(), isEmpty);
      },
    );
  });

  group('performGlobalAction', () {
    test('sends action id', () async {
      mockNative({'performGlobalAction': true});
      expect(
        await FlutterAccessibilityService.performGlobalAction(
          GlobalAction.globalActionLockScreen,
        ),
        isTrue,
      );
      expect(log, [
        isMethodCall('performGlobalAction', arguments: {'action': 8}),
      ]);
    });

    test(
      'short-circuits GlobalAction.unknown without calling native',
      () async {
        mockNative({'performGlobalAction': true});
        expect(
          await FlutterAccessibilityService.performGlobalAction(
            GlobalAction.unknown,
          ),
          isFalse,
        );
        expect(log, isEmpty);
      },
    );

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(
        await FlutterAccessibilityService.performGlobalAction(
          GlobalAction.globalActionBack,
        ),
        isFalse,
      );
    });
  });

  group('dispatchGesture', () {
    const swipe = GestureDescription(
      strokes: [
        GestureStroke(
          path: [GesturePoint(500, 1500), GesturePoint(500, 300)],
          startTime: 0,
          duration: 400,
        ),
      ],
    );

    test('wraps serialized strokes under "strokes" key', () async {
      mockNative({'dispatchGesture': true});
      expect(await FlutterAccessibilityService.dispatchGesture(swipe), isTrue);
      expect(log, [
        isMethodCall(
          'dispatchGesture',
          arguments: {
            'strokes': [
              {
                'path': [
                  {'x': 500.0, 'y': 1500.0},
                  {'x': 500.0, 'y': 300.0},
                ],
                'startTime': 0,
                'duration': 400,
              },
            ],
          },
        ),
      ]);
    });

    test('returns false when gesture is cancelled', () async {
      mockNative({'dispatchGesture': false});
      expect(await FlutterAccessibilityService.dispatchGesture(swipe), isFalse);
    });

    test('returns false on PlatformException', () async {
      mockNativeThrows();
      expect(await FlutterAccessibilityService.dispatchGesture(swipe), isFalse);
    });
  });

  group('streams on non-Android hosts', () {
    // The test host is never Android, so both getters must throw.
    test('accessStream throws', () {
      expect(() => FlutterAccessibilityService.accessStream, throwsException);
    });

    test('onAccessibilityServiceStatusChanged throws', () {
      expect(
        () => FlutterAccessibilityService.onAccessibilityServiceStatusChanged,
        throwsException,
      );
    });
  });
}
