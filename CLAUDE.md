# CLAUDE.md

Flutter plugin (`flutter_accessibility_service`, published on pub.dev) that exposes Android's `AccessibilityService` to Dart: streaming accessibility events, performing node/global actions, dispatching gestures, and showing a Flutter overlay window. **Android only** — there is no iOS/web implementation.

## Commands

```bash
flutter pub get                 # install deps (root + example/ separately)
flutter test                    # run all Dart unit tests in test/
flutter test test/models_test.dart   # run one file
flutter analyze                 # lints (flutter_lints, see analysis_options.yaml)
dart format lib test            # format before committing

cd example && flutter run       # run the example app on an Android device/emulator
```

There are no native (Java/JUnit) tests; native behaviour must be verified manually on a device via `example/`.

## Layout

```
lib/
  flutter_accessibility_service.dart  # Public static API; MethodChannel + 2 EventChannels
  accessibility_event.dart            # AccessibilityEvent / ScreenBounds, parsed from native JSON
  constants.dart                      # EventType, ContentChangeTypes, WindowType, NodeAction, GlobalAction enums
  gesture_description.dart            # GesturePoint / GestureStroke / GestureDescription
  config/overlay_config.dart          # OverlayConfig (width/height/gravity/clickableThrough)
  config/overlay_gravity.dart         # OverlayGravity -> android.view.Gravity int values
android/src/main/java/slayer/accessibility/service/flutter_accessibility_service/
  FlutterAccessibilityServicePlugin.java  # Channel handlers, permission flow, overlay engine setup
  AccessibilityListener.java              # The AccessibilityService: builds event JSON, node cache, overlay, gestures
  AccessibilityReceiver.java              # BroadcastReceiver that forwards events to the EventChannel sink
  Utils.java                              # isAccessibilitySettingsOn, node lookup, action-argument Bundles
  Constants.java                          # Intent / SharedPreferences keys
example/                                  # Demo app; its AndroidManifest + res/xml/accessibilityservice.xml
                                          # are the reference setup for consumers
test/                                     # Dart unit tests (see Testing)
```

## Architecture

### Channels (names must match on both sides)

| Dart | Java | Purpose |
|---|---|---|
| `MethodChannel('x-slayer/accessibility_channel')` | `CHANNEL_TAG` | all request/response calls |
| `EventChannel('x-slayer/accessibility_event')` | `EVENT_TAG` | accessibility events (JSON **string**) |
| `EventChannel('x-slayer/accessibility_status')` | `STATUS_EVENT_TAG` | `bool` service-enabled status, emitted on listen and on change |

### Method-channel contract

| Method | Args (Dart → Java) | Returns |
|---|---|---|
| `isAccessibilityPermissionEnabled` | — | `bool` |
| `requestAccessibilityPermission` | — | `bool` (after the settings activity returns) |
| `performActionById` | `{nodeId: mapId, nodeAction: int, extras: dynamic}` | `bool` (false if node not in cache) |
| `performGlobalAction` | `{action: int}` | `bool` |
| `getSystemActions` | — | `List<int>`; **errors** (`SDK_INT_ERROR`) if service disabled |
| `showOverlayWindow` | `OverlayConfig.toJson()` | `bool`; **errors** `ERR:OVERLAY` if entry point missing |
| `hideOverlayWindow` | — | `bool` |
| `dispatchGesture` | `{strokes: GestureDescription.toJson()}` | `bool` (false if cancelled, API < 24, or service not running) |

If you add/rename a method or argument key, change **both** `lib/flutter_accessibility_service.dart` and `FlutterAccessibilityServicePlugin.onMethodCall`, and add a channel test.

### Event flow (native → Dart)

1. `AccessibilityListener.onAccessibilityEvent` builds a `HashMap` (top-level node + up to `maxDepth` sub-nodes), stores each `AccessibilityNodeInfo` in a static `LruCache` keyed by a generated `mapId` (`windowId_className_text_contentDescription`).
2. The map is serialized with **Gson** into SharedPreferences (`SHARED_PREFS_TAG` / `ACCESSIBILITY_NODE`), then a broadcast `accessibility_event` is sent.
3. `AccessibilityReceiver` reads the JSON string from SharedPreferences and pushes it to the event sink.
4. Dart `accessStream` does `jsonDecode` → `AccessibilityEvent.fromMap`.

So JSON keys in `AccessibilityListener` (`mapId`, `capturedText`, `parentActions`, `subNodesActions`, `screenBounds`, …) are the contract for `AccessibilityEvent.fromMap`. Keep them in sync.

`performAction` passes `event.mapId` (not `nodeId`) — the native side looks the node up in the LRU cache, so it only works for recently-seen nodes.

### Overlay

The overlay runs a **separate Flutter engine** started in `onAttachedToActivity` from a Dart entry point that must be named exactly `accessibilityOverlay` and annotated `@pragma("vm:entry-point")` in the consumer's `main.dart`. If missing, `supportOverlay` is false and `showOverlayWindow` returns false.

### Consumer setup (documented in README)

Apps must declare `AccessibilityListener` as a `<service>` with `BIND_ACCESSIBILITY_SERVICE` and an `accessibilityservice.xml` (see `example/android/...`). `canPerformGestures="true"` is required for `dispatchGesture`; `canRetrieveWindowContent="true"` for node data.

## Conventions & gotchas

- Public API is a static-only class (`FlutterAccessibilityService._()`); no instances.
- Every method-channel call catches `PlatformException`, `log`s it, and returns `false` / `[]` — never throws. Keep this behaviour for new methods.
- `NodeAction.unknown` / `GlobalAction.unknown` short-circuit to `false` without hitting native.
- Enum values carry the **Android integer constant** as `id`; Dart lookups are `firstWhereOrNull(id == x)`. Enum ids must match Android docs. `NodeAction` intentionally contains overlapping ids (`focus*`, `movementGranularity*` share ids with `action*`), so declaration order matters — first match wins.
- `accessStream` and `onAccessibilityServiceStatusChanged` throw on non-Android (`Platform.isAndroid`), including in `flutter test` on a desktop host; these streams can't be unit-tested end to end without refactoring.
- `AccessibilityEvent.fromMap` quirks: `eventTime` is `DateTime.now()` on the Dart side (the native `eventTime` is ignored); `text` uses `.toString()` so a missing `capturedText` becomes the string `"null"`; `subNodes`/`actions` default to `[]`, not null.
- `performAction` extras are interpreted per action in `Utils.bundleIdentifier` (String for `actionSetText`/HTML element, bool for movement granularity, `{start, end}` map for `actionSetSelection`). Adding a new action with arguments needs a Java branch there.
- Android build: Java 8 source level, `compileSdkVersion 34`, `minSdkVersion 16` (many features are gated by `Build.VERSION.SDK_INT` at runtime), Gson is the only native dependency.
- Receivers are registered with `RECEIVER_EXPORTED` on API 34+; keep that branch when touching registration.

## Testing

Dart tests live in `test/` and run on the host VM with mocked channels:

- `flutter_accessibility_service_test.dart` — method-channel contract: method names, exact argument maps, return value handling, `PlatformException` → `false`/`[]`, `unknown` short-circuits, and streams throwing off-Android. Uses `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler`; helpers `mockNative({...})` / `mockNativeThrows()`.
- `accessibility_event_test.dart` — parses a Gson-shaped JSON fixture mirroring `AccessibilityListener` output; covers enum mapping, fallbacks, sub-nodes, empty payloads.
- `models_test.dart` — `OverlayConfig`, `OverlayGravity` values vs `android.view.Gravity`, gesture serialization, enum id uniqueness and spot-checks.

When changing the native JSON shape, update the fixture in `accessibility_event_test.dart`. When adding a method, add a test asserting its exact `MethodCall` arguments.

## Releasing

1. Bump `version` in `pubspec.yaml`.
2. Add a `# x.y.z` section at the top of `CHANGELOG.md` (bulleted, imperative).
3. Update README if the public API or setup changed.
4. `flutter test && flutter analyze && dart pub publish --dry-run`.

Commit messages follow Conventional Commits (`feat(gestures): ...`, `build(release): ...`, `docs(changelog): ...`).
