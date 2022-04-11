import 'dart:developer';

import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
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
              TextButton(
                onPressed: () async {
                  await FlutterAccessibilityService
                      .requestAccessibilityPermission();
                },
                child: const Text("Request Permission"),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  FlutterAccessibilityService.accessStream.listen((event) {
                    log("Current Event: $event");
                  });
                },
                child: const Text("Request Permission"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
