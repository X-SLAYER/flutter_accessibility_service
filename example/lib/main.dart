import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void handleAccessiblityStream() {
    if (_subscription?.isPaused ?? false) {
      _subscription?.resume();
      return;
    }
    _subscription =
        FlutterAccessibilityService.accessStream.listen((event) async {
      log("$event");
      setState(() {
        events.add(event);
      });
      if (event.subNodes!.map((e) => e.text).contains('Start chat')) {
        final frame = event.subNodes!
            .firstWhereOrNull((element) => element.text == 'Start chat');
        if (frame != null) {
          final status = await FlutterAccessibilityService.performAction(
            frame.nodeId!,
            NodeAction.actionClick,
          );
          log('is Click Performed ? : $status : ${frame.nodeId!}');
        }
        // for (var element in event.subNodes!) {
        //   if (element.actions!.contains(NodeAction.focusInput)) {
        //     final status = await FlutterAccessibilityService.performAction(
        //       element.nodeId!,
        //       NodeAction.focusInput,
        //     );
        //     log('is Click Performed ? : $status : ${element.nodeId!}');
        //   }
        // }
      }
    });
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
                      onPressed: () {
                        FlutterAccessibilityService.takeScreenShot();
                      },
                      child: const Text("Take ScreenShot"),
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
                    subtitle: Text(events[index]!
                            .subNodes!
                            .map((e) => e.actions)
                            .expand((element) => element!)
                            .contains(NodeAction.actionClick)
                        ? 'Have Action to click'
                        : ''),
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
