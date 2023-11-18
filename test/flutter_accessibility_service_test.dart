import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel methodChannel =
      MethodChannel('x-slayer/accessibility_channel');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'requestAccessibilityPermission':
          return true;
        case 'isAccessibilityPermissionEnabled':
          return true;
        case 'performActionById':
          return true;
        case 'showOverlayWindow':
          return true;
        case 'hideOverlayWindow':
          return true;
        case 'getSystemActions':
          return [];
        case 'performGlobalAction':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
  });

  test('requestAccessibilityPermission method test', () async {
    final result =
        await FlutterAccessibilityService.requestAccessibilityPermission();
    expect(result, true);
    expect(log, <Matcher>[
      isMethodCall('requestAccessibilityPermission', arguments: null),
    ]);
  });

  test('isAccessibilityPermissionEnabled method test', () async {
    final result =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    expect(result, true);
    expect(log, <Matcher>[
      isMethodCall('isAccessibilityPermissionEnabled', arguments: null),
    ]);
  });

  test('performAction method test', () async {
    final event = AccessibilityEvent(mapId: "testId");
    final result = await FlutterAccessibilityService.performAction(
        event, NodeAction.unknown);
    expect(result, false);
    expect(log, isEmpty);
  });

  test('showOverlayWindow method test', () async {
    final result = await FlutterAccessibilityService.showOverlayWindow();
    expect(result, true);
    expect(log, <Matcher>[
      isMethodCall('showOverlayWindow', arguments: null),
    ]);
  });

  test('hideOverlayWindow method test', () async {
    final result = await FlutterAccessibilityService.hideOverlayWindow();
    expect(result, true);
    expect(log, <Matcher>[
      isMethodCall('hideOverlayWindow', arguments: null),
    ]);
  });

  test('getSystemActions method test', () async {
    final result = await FlutterAccessibilityService.getSystemActions();
    expect(result, isEmpty);
    expect(log, <Matcher>[
      isMethodCall('getSystemActions', arguments: null),
    ]);
  });

  test('performGlobalAction method test', () async {
    final result = await FlutterAccessibilityService.performGlobalAction(
      GlobalAction.unknown,
    );
    expect(result, false);
    expect(log, isEmpty);
  });
}
