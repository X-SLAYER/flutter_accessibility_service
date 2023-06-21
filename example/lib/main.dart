import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

import 'package:collection/collection.dart';
import 'package:flutter_accessibility_service_example/overlay.dart';

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
  List<AccessibilityEvent?> events = [];
  DateTime eventDateTime = DateTime.now();

  bool foundSearchField = false;
  bool hasBeenClicked = false;

  @override
  void initState() {
    super.initState();
  }

  void handleAccessiblityStream() {
    foundSearchField = false;
    hasBeenClicked = false;
    if (_subscription?.isPaused ?? false) {
      _subscription?.resume();
      return;
    }
    _subscription =
        FlutterAccessibilityService.accessStream.listen((event) async {
      setState(() {
        events.add(event);
      });
      // automateYouTube(event);
      if (event.packageName!.contains('youtube')) {
        log('$event');
      }
      if (event.packageName!.contains('youtube') && event.isFocused!) {
        eventDateTime = event.eventTime!;
        await FlutterAccessibilityService.showOverlayWindow();
      } else if (eventDateTime.difference(event.eventTime!).inSeconds.abs() >
              2 ||
          (event.eventType == EventType.typeWindowStateChanged &&
              !event.isFocused!)) {
        await FlutterAccessibilityService.hideOverlayWindow();
      }
    });
  }

  void automateYouTube(AccessibilityEvent event) async {
    if (!event.packageName!.contains('youtube')) return;
    log('$event');
    final searchIt = event.subNodes!.firstWhereOrNull(
      (element) => element.actions!.contains(NodeAction.actionScrollForward),
    );
    log('$searchIt', name: 'YES WE CAN');
    if (searchIt != null) {
      final status = await doAction(searchIt, NodeAction.actionScrollForward);

      log('$status => ${searchIt.actions!.first}', name: 'Action done');
    }
  }

  Future<bool> doAction(
    SubNodes node,
    NodeAction action, [
    dynamic argument,
  ]) async {
    if (node.nodeId == null && node.text == null) return false;
    return node.nodeId != null
        ? await FlutterAccessibilityService.performActionById(
            node.nodeId!,
            action,
            argument,
          )
        : await FlutterAccessibilityService.performActionByText(
            node.text!,
            action,
            argument,
          );
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
                  children: [
                    TextButton(
                      onPressed: () async {
                        await FlutterAccessibilityService
                            .requestAccessibilityPermission();
                      },
                      child: const Text("Request Permission"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () async {
                        final bool res = await FlutterAccessibilityService
                            .isAccessibilityPermissionEnabled();
                        log("Is enabled: $res");
                      },
                      child: const Text("Check Permission"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: handleAccessiblityStream,
                      child: const Text("Start Stream"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        _subscription?.cancel();
                      },
                      child: const Text("Stop Stream"),
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
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (_, index) => ListTile(
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
