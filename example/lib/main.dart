import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/config/overlay_config.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/gesture_description.dart';

import 'package:flutter_accessibility_service_example/overlay.dart';

import 'package:collection/collection.dart';

@pragma("vm:entry-point")
void accessibilityOverlay() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlockingOverlay(),
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AccessibilityEvent>? _subscription;
  StreamSubscription<bool>? _statusSubscription;

  List<AccessibilityEvent?> events = [];
  DateTime eventDateTime = DateTime.now();
  bool foundSearchField = false;
  bool setText = false;
  bool clickFirstSearch = false;

  @override
  void initState() {
    super.initState();
  }

  void handleAccessibilityStream() {
    foundSearchField = false;
    setText = false;
    if (_subscription?.isPaused ?? false) {
      _subscription?.resume();
      return;
    }
    _subscription =
        FlutterAccessibilityService.accessStream.listen((event) async {
      if (event.packageName!.contains('slayer.accessibility.service')) {
        return;
      }
      setState(() {
        events.add(event);
      });
      // automateScroll(event);
      // log("$event");
      // automateWikipedia(event);
      handleOverlay(event);
    });
  }

  void handleAccessibilityStatus() {
    if (_statusSubscription?.isPaused ?? false) {
      _statusSubscription?.resume();
      return;
    }
    _statusSubscription = FlutterAccessibilityService
        .onAccessibilityServiceStatusChanged
        .listen((event) {
      log("Accessibility Status changed: $event");
    });
  }

  void handleOverlay(AccessibilityEvent event) async {
    if (event.packageName!.contains('youtube')) {
      log('$event');
    }
    if (event.packageName!.contains('youtube') ||
        ((event.nodeId != null &&
                event.nodeId!.contains('com.google.android.youtube'))) &&
            event.isFocused!) {
      eventDateTime = event.eventTime!;
      await FlutterAccessibilityService.showOverlayWindow(
        const OverlayConfig(),
      );
    } else if (eventDateTime.difference(event.eventTime!).inSeconds.abs() > 2 ||
        (event.eventType == EventType.typeWindowStateChanged &&
            !event.isFocused!)) {
      await FlutterAccessibilityService.hideOverlayWindow();
    }
  }

  void automateWikipedia(AccessibilityEvent event) async {
    if (!event.packageName!.contains('wikipedia')) return;
    log('$event');
    final searchIt = [...event.subNodes!, event].firstWhereOrNull(
      (element) => element.text == 'Search Wikipedia' && element.isClickable!,
    );
    log("Searchable Field: $searchIt");
    if (searchIt != null) {
      await doAction(searchIt, NodeAction.actionClick);
      final editField = [...event.subNodes!, event].firstWhereOrNull(
        (element) => element.text == 'Search Wikipedia' && element.isEditable!,
      );
      if (editField != null) {
        await doAction(editField, NodeAction.actionSetText, "Lionel Messi");
      }
      final item = [...event.subNodes!, event].firstWhereOrNull(
        (element) => element.text == 'Messi–Ronaldo rivalry',
      );
      if (item != null) {
        await doAction(item, NodeAction.actionSelect);
      }
    }
  }

  Future<bool> doAction(
    AccessibilityEvent node,
    NodeAction action, [
    dynamic argument,
  ]) async {
    return await FlutterAccessibilityService.performAction(
      node,
      action,
      argument,
    );
  }

  void automateScroll(AccessibilityEvent node) async {
    if (!node.packageName!.contains('youtube')) return;
    log("$node");
    if (node.isFocused!) {
      final scrollableNode = findScrollableNode(node);
      log('$scrollableNode', name: 'SCROLLABLE- XX');
      if (scrollableNode != null) {
        await FlutterAccessibilityService.performAction(
          node,
          NodeAction.actionScrollForward,
        );
      }
    }
  }

  AccessibilityEvent? findScrollableNode(AccessibilityEvent rootNode) {
    if (rootNode.isScrollable! &&
        rootNode.actions!.contains(NodeAction.actionScrollForward)) {
      return rootNode;
    }
    if (rootNode.subNodes!.isEmpty) return null;
    for (int i = 0; i < rootNode.subNodes!.length; i++) {
      final childNode = rootNode.subNodes![i];
      final scrollableChild = findScrollableNode(childNode);
      if (scrollableChild != null) {
        return scrollableChild;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20.0,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await FlutterAccessibilityService
                            .requestAccessibilityPermission();
                      },
                      child: const Text("Request Permission"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final bool res = await FlutterAccessibilityService
                            .isAccessibilityPermissionEnabled();
                        log("Is enabled: $res");
                      },
                      child: const Text("Check Permission"),
                    ),
                    TextButton(
                      onPressed: handleAccessibilityStream,
                      child: const Text("Start Stream"),
                    ),
                    TextButton(
                      onPressed: handleAccessibilityStatus,
                      child: const Text("Start Status Stream"),
                    ),
                    TextButton(
                      onPressed: () {
                        _subscription?.cancel();
                      },
                      child: const Text("Stop Stream"),
                    ),
                    TextButton(
                      onPressed: () {
                        _statusSubscription?.cancel();
                      },
                      child: const Text("Stop Status Stream"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FlutterAccessibilityService.performGlobalAction(
                          GlobalAction.globalActionTakeScreenshot,
                        );
                      },
                      child: const Text("Take ScreenShot"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final list = await FlutterAccessibilityService
                            .getSystemActions();
                        log('$list');
                      },
                      child: const Text("List GlobalActions"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Tap at the center of a typical screen (500, 1000)
                        final bool ok =
                            await FlutterAccessibilityService.dispatchGesture(
                          const GestureDescription(
                            strokes: [
                              GestureStroke(
                                path: [GesturePoint(500, 1000)],
                                startTime: 0,
                                duration: 100,
                              ),
                            ],
                          ),
                        );
                        log('Tap gesture result: $ok');
                      },
                      child: const Text("Tap Gesture"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Swipe up: from (500, 1500) to (500, 300) over 400 ms
                        final bool ok =
                            await FlutterAccessibilityService.dispatchGesture(
                          const GestureDescription(
                            strokes: [
                              GestureStroke(
                                path: [
                                  GesturePoint(500, 1500),
                                  GesturePoint(500, 300),
                                ],
                                startTime: 0,
                                duration: 400,
                              ),
                            ],
                          ),
                        );
                        log('Swipe up gesture result: $ok');
                      },
                      child: const Text("Swipe Up"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Double-tap at (500, 1000): two quick strokes 50 ms apart
                        final bool ok =
                            await FlutterAccessibilityService.dispatchGesture(
                          const GestureDescription(
                            strokes: [
                              GestureStroke(
                                path: [GesturePoint(500, 1000)],
                                startTime: 0,
                                duration: 100,
                              ),
                              GestureStroke(
                                path: [GesturePoint(500, 1000)],
                                startTime: 150,
                                duration: 100,
                              ),
                            ],
                          ),
                        );
                        log('Double-tap gesture result: $ok');
                      },
                      child: const Text("Double Tap"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          events.clear();
                        });
                      },
                      child: const Text("Clear List"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (_, index) => ListTile(
                    onTap: () {
                      final haveActions = (events[index]!.subNodes ?? [])
                          .map((e) => e.actions)
                          .expand((element) => element!)
                          .contains(NodeAction.actionClick);
                      final firstElement = events[index]!.subNodes!.firstWhere(
                          (element) => element.actions!
                              .contains(NodeAction.actionClick));
                      if (haveActions) {
                        log('$firstElement');
                        doAction(firstElement, NodeAction.actionClick);
                      }
                    },
                    title: Text(events[index]!.packageName!),
                    subtitle: Text(
                      (events[index]!.subNodes ?? [])
                              .map((e) => e.actions)
                              .expand((element) => element!)
                              .contains(NodeAction.actionClick)
                          ? 'Have Action to click'
                          : '',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
