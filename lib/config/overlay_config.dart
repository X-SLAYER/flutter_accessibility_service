import 'package:flutter_accessibility_service/config/overlay_gravity.dart';

/// OverlayConfig class
/// This class is used to configure the overlay window
class OverlayConfig {
  /// Whether the overlay window is clickable through
  /// If true, the overlay window will not intercept touch events
  final bool clickableThrough;

  /// The width of the overlay window
  /// If -1, the width will be set to the width of the screen
  final int width;

  /// The height of the overlay window
  /// If -1, the height will be set to the height of the screen
  final int height;

  /// The gravity of the overlay window
  /// This determines where the overlay window will be displayed on the screen
  /// The default value is OverlayGravity.top
  final OverlayGravity gravity;

  const OverlayConfig({
    this.clickableThrough = false,
    this.width = -1,
    this.height = -1,
    this.gravity = OverlayGravity.top,
  });

  OverlayConfig copyWith({
    bool? clickableThrough,
    int? width,
    int? height,
    OverlayGravity? gravity,
  }) {
    return OverlayConfig(
      clickableThrough: clickableThrough ?? this.clickableThrough,
      width: width ?? this.width,
      height: height ?? this.height,
      gravity: gravity ?? this.gravity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clickableThrough': clickableThrough,
      'width': width,
      'height': height,
      'gravity': gravity.value,
    };
  }
}
