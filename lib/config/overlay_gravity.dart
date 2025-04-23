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
          OverlayGravity.top.combinedValue([OverlayGravity.left]),
        OverlayGravity.topRight =>
          OverlayGravity.top.combinedValue([OverlayGravity.right]),
        OverlayGravity.bottomLeft =>
          OverlayGravity.bottom.combinedValue([OverlayGravity.left]),
        OverlayGravity.bottomRight =>
          OverlayGravity.bottom.combinedValue([OverlayGravity.right]),
      };

  int combinedValue(List<OverlayGravity> gravities) =>
      [this, ...gravities].fold(0, (prev, g) => prev | g.value);
}
