// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterAccessibilityService {
  static const MethodChannel _methodeChannel =
      MethodChannel('x-slayer/accessibility_channel');
  static const EventChannel _eventChannel =
      EventChannel('x-slayer/accessibility_event');
  static Stream<dynamic> _stream = const Stream.empty();

  /// stream incoming Accessibility events
  static Stream get accessStream {
    if (Platform.isAndroid) {
      _stream =
          _eventChannel.receiveBroadcastStream().map<dynamic>((event) => event);
      return _stream;
    }
    throw Exception("Accessibility API exclusively available on Android!");
  }

  /// request accessibility permession
  /// it will open the accessibility settings page
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _methodeChannel.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (error) {
      log("$error");
    }
  }

  /// check if accessibility permession is enebaled
  static Future<bool> isAccessibilityPermissionEnabled() async {
    try {
      return await _methodeChannel
          .invokeMethod('isAccessibilityPermissionEnabled');
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }
}
