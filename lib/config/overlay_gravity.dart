enum OverlayGravity {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  int get value => switch (this) {
        OverlayGravity.top => 48,
        OverlayGravity.bottom => 80,
        OverlayGravity.left => 3,
        OverlayGravity.right => 5,
        OverlayGravity.topLeft =>
          OverlayGravity.top._combinedValue([OverlayGravity.left]),
        OverlayGravity.topRight =>
          OverlayGravity.top._combinedValue([OverlayGravity.right]),
        OverlayGravity.bottomLeft =>
          OverlayGravity.bottom._combinedValue([OverlayGravity.left]),
        OverlayGravity.bottomRight =>
          OverlayGravity.bottom._combinedValue([OverlayGravity.right]),
      };

  int _combinedValue(List<OverlayGravity> gravities) =>
      [this, ...gravities].fold(0, (prev, g) => prev | g.value);
}
