/// A single x/y coordinate used to define a gesture path.
class GesturePoint {
  final double x;
  final double y;

  const GesturePoint(this.x, this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

/// One continuous touch stroke within a [GestureDescription].
///
/// [path]      — ordered list of points that define the stroke.
/// [startTime] — milliseconds after the gesture starts before this stroke begins (default 0).
/// [duration]  — how long the stroke lasts in milliseconds (default 100).
class GestureStroke {
  final List<GesturePoint> path;
  final int startTime;
  final int duration;

  const GestureStroke({
    required this.path,
    this.startTime = 0,
    this.duration = 100,
  });

  Map<String, dynamic> toJson() => {
        'path': path.map((p) => p.toJson()).toList(),
        'startTime': startTime,
        'duration': duration,
      };
}

/// Describes a compound gesture made of one or more [GestureStroke]s.
///
/// Maps to Android's `android.accessibilityservice.GestureDescription`.
/// Requires Android 7.0 (API 24) or higher.
///
/// Example — swipe up:
/// ```dart
/// GestureDescription(
///   strokes: [
///     GestureStroke(
///       path: [GesturePoint(500, 1500), GesturePoint(500, 300)],
///       startTime: 0,
///       duration: 400,
///     ),
///   ],
/// )
/// ```
class GestureDescription {
  final List<GestureStroke> strokes;

  const GestureDescription({required this.strokes});

  List<Map<String, dynamic>> toJson() =>
      strokes.map((s) => s.toJson()).toList();
}
