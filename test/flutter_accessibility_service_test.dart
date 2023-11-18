import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_accessibility_service');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
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

  tearDown(() {});
}
