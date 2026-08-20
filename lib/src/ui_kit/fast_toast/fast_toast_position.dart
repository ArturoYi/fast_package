import 'package:flutter/widgets.dart';

/// Vertical placement of a toast on the overlay.
/// Toast 在 Overlay 上的垂直位置。
enum FastToastPosition {
  /// Top-center, inset from the top edge.
  /// 顶部居中，距上边缘有内边距。
  top,

  /// Screen center.
  /// 屏幕中央。
  center,

  /// Bottom-center, inset from the bottom edge.
  /// 底部居中，距下边缘有内边距。
  bottom;

  /// Alignment used to place the toast in a [Stack] / [Align].
  /// 用于在 [Stack] / [Align] 中放置 Toast 的对齐。
  Alignment get alignment => switch (this) {
        FastToastPosition.top => Alignment.topCenter,
        FastToastPosition.center => Alignment.center,
        FastToastPosition.bottom => Alignment.bottomCenter,
      };

  /// Extra gap beyond [MediaQueryData.viewPadding] for top / bottom.
  /// 顶部 / 底部在 [MediaQueryData.viewPadding] 之外的额外间距。
  ///
  /// Keyboard insets are applied on a compositing layer, not this value.
  /// 键盘 insets 在合成层上处理，不包含在此值中。
  double get edgeInset => switch (this) {
        FastToastPosition.top || FastToastPosition.bottom => 24,
        FastToastPosition.center => 0,
      };
}
