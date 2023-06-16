import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';

class FlutterAccessibilityService {
  FlutterAccessibilityService._();

  static const MethodChannel _methodChannel =
      MethodChannel('x-slayer/accessibility_channel');
  static const EventChannel _eventChannel =
      EventChannel('x-slayer/accessibility_event');
  static Stream<AccessibilityEvent>? _stream;

  /// stream the incoming Accessibility events
  static Stream<AccessibilityEvent> get accessStream {
    if (Platform.isAndroid) {
      _stream ??=
          _eventChannel.receiveBroadcastStream().map<AccessibilityEvent>(
                (event) => AccessibilityEvent.fromMap(event),
              );
      return _stream!;
    }
    throw Exception("Accessibility API exclusively available on Android!");
  }

  /// request accessibility permission
  /// it will open the accessibility settings page and return `true` once the permission granted.
  static Future<bool> requestAccessibilityPermission() async {
    try {
      return await _methodChannel
          .invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (error) {
      log("$error");
      return Future.value(false);
    }
  }

  /// check if accessibility permession is enebaled
  static Future<bool> isAccessibilityPermissionEnabled() async {
    try {
      return await _methodChannel
          .invokeMethod('isAccessibilityPermissionEnabled');
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// Take a system screenshot and save it to the device's external storage.
  static Future<bool> takeScreenShot() async {
    try {
      return await _methodChannel.invokeMethod<bool?>('takeScreenShot') ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// Perform action click
  static Future<bool> performClick(String nodeId) async {
    try {
      return await _methodChannel
              .invokeMethod<bool?>('performClick', {"nodeId": nodeId}) ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }
}
