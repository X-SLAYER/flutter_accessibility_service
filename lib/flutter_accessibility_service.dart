import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';

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

  /// An action that can be performed on an `AccessibilityNodeInfo`
  /// pass the necessary arguments depends on each action to avoid any errors
  /// See more: https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo.AccessibilityAction
  static Future<bool> performAction(
    String nodeId,
    NodeAction action, [
    dynamic arguments,
  ]) async {
    try {
      if (action == NodeAction.unknown) return false;
      return await _methodChannel.invokeMethod<bool?>(
            'performAction',
            {
              "nodeId": nodeId,
              "nodeAction": action.id,
              "extras": arguments,
            },
          ) ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// Show an overlay window of `TYPE_ACCESSIBILITY_OVERLAY`
  ///
  /// Dont forget to add the overlay entrypoint in the main level.
  ///
  /// example:
  /// ```dart
  /// @pragma("vm:entry-point")
  /// void accessibilityOverlay() {
  ///   runApp(
  ///     const MaterialApp(
  ///       debugShowCheckedModeBanner: false,
  ///       home: BlockingOverlay(),
  ///     ),
  ///   );
  /// }
  /// ```
  static Future<bool> showOverlayWindow() async {
    try {
      return await _methodChannel.invokeMethod<bool?>('showOverlayWindow') ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// Hide the overlay window
  static Future<bool> hideOverlayWindow() async {
    try {
      return await _methodChannel.invokeMethod<bool?>('hideOverlayWindow') ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }
}
