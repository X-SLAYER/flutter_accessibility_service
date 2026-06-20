import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';

import 'config/overlay_config.dart';
import 'gesture_description.dart';

class FlutterAccessibilityService {
  FlutterAccessibilityService._();

  static const MethodChannel _methodChannel =
      MethodChannel('x-slayer/accessibility_channel');
  static const EventChannel _eventChannel =
      EventChannel('x-slayer/accessibility_event');
  static const EventChannel _statusChannel =
      EventChannel('x-slayer/accessibility_status');
  static Stream<AccessibilityEvent>? _stream;
  static Stream<bool>? _statusStream;

  /// stream the incoming Accessibility events
  static Stream<AccessibilityEvent> get accessStream {
    if (Platform.isAndroid) {
      _stream ??=
          _eventChannel.receiveBroadcastStream().map<AccessibilityEvent>(
                (event) => AccessibilityEvent.fromMap(jsonDecode(event)),
              );
      return _stream!;
    }
    throw Exception("Accessibility API exclusively available on Android!");
  }

  /// Emits `true` when the accessibility service is enabled and `false` when
  /// it is disabled. The current state is always emitted immediately on listen.
  static Stream<bool> get onAccessibilityServiceStatusChanged {
    if (Platform.isAndroid) {
      _statusStream ??= _statusChannel
          .receiveBroadcastStream()
          .map<bool>((event) => event as bool);
      return _statusStream!;
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

  /// check if accessibility permission is enabled
  static Future<bool> isAccessibilityPermissionEnabled() async {
    try {
      return await _methodChannel
          .invokeMethod('isAccessibilityPermissionEnabled');
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// An action that can be performed on an `AccessibilityNodeInfo` by nodeId
  /// pass the necessary arguments depends on each action to avoid any errors
  /// See more: https://developer.android.com/reference/android/view/accessibility/AccessibilityNodeInfo.AccessibilityAction
  static Future<bool> performAction(
    AccessibilityEvent event,
    NodeAction action, [
    dynamic arguments,
  ]) async {
    try {
      if (action == NodeAction.unknown) return false;
      return await _methodChannel.invokeMethod<bool?>(
            'performActionById',
            {
              "nodeId": event.mapId,
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
  /// Don't forget to add the overlay entrypoint in the main level.
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
  static Future<bool> showOverlayWindow([
    OverlayConfig config = const OverlayConfig(),
  ]) async {
    try {
      return await _methodChannel.invokeMethod<bool?>(
            'showOverlayWindow',
            config.toJson(),
          ) ??
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

  /// Returns a list of system actions available in the system right now.
  /// System actions that correspond to the `GlobalAction`
  static Future<List<GlobalAction>> getSystemActions() async {
    try {
      final list = await _methodChannel
              .invokeMethod<List<dynamic>>('getSystemActions') ??
          [];
      return list
          .map(
            (e) => GlobalAction.values.firstWhere(
              (element) => element.id == e,
              orElse: () => GlobalAction.unknown,
            ),
          )
          .toList();
    } on PlatformException catch (error) {
      log("$error");
      return [];
    }
  }

  /// Dispatches a gesture on the screen via the accessibility service.
  ///
  /// Requires Android 7.0 (API 24) or higher. Returns `true` when the gesture
  /// completes successfully, or `false` if it was cancelled or the service is
  /// not running.
  ///
  /// Example — tap at (500, 1000):
  /// ```dart
  /// await FlutterAccessibilityService.dispatchGesture(
  ///   GestureDescription(
  ///     strokes: [
  ///       GestureStroke(
  ///         path: [GesturePoint(500, 1000)],
  ///         startTime: 0,
  ///         duration: 100,
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  ///
  /// Example — swipe up from (500, 1500) to (500, 300):
  /// ```dart
  /// await FlutterAccessibilityService.dispatchGesture(
  ///   GestureDescription(
  ///     strokes: [
  ///       GestureStroke(
  ///         path: [GesturePoint(500, 1500), GesturePoint(500, 300)],
  ///         startTime: 0,
  ///         duration: 400,
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  static Future<bool> dispatchGesture(GestureDescription gesture) async {
    try {
      return await _methodChannel.invokeMethod<bool?>(
            'dispatchGesture',
            {'strokes': gesture.toJson()},
          ) ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }

  /// Performs a global action.
  /// Such an action can be performed at any moment regardless of the current application or user location in that application
  /// For example going back, going home, opening recents, etc.
  ///
  /// Note: The global action themselves give no information about the current availability of their corresponding actions.
  /// To determine if a global action is available, use `getSystemActions()`
  static Future<bool> performGlobalAction(GlobalAction action) async {
    try {
      if (action == GlobalAction.unknown) return false;
      return await _methodChannel.invokeMethod<bool?>(
            'performGlobalAction',
            {"action": action.id},
          ) ??
          false;
    } on PlatformException catch (error) {
      log("$error");
      return false;
    }
  }
}
