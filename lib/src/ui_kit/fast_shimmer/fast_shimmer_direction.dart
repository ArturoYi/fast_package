import 'package:flutter/widgets.dart';

/// Defines the direction in which the shimmer highlight travels.
/// 定义 shimmer 高光扫过的方向。
///
/// Used by [FastShimmerTheme] and [FastShimmerScope] to build the animated
/// [LinearGradient].
/// 供 [FastShimmerTheme] 与 [FastShimmerScope] 构建动画 [LinearGradient] 使用。
enum FastShimmerDirection {
  /// Highlight moves from left to right.
  /// 高光从左向右移动。
  leftToRight,

  /// Highlight moves from right to left.
  /// 高光从右向左移动。
  rightToLeft,

  /// Highlight moves from top to bottom.
  /// 高光从上向下移动。
  topToBottom,

  /// Highlight moves from bottom to top.
  /// 高光从下向上移动。
  bottomToTop,

  /// Highlight moves diagonally from top-left to bottom-right.
  /// 高光沿对角线从左上向右下移动。
  diagonal;

  /// Returns a [LinearGradient] whose begin/end match this direction.
  /// 返回 begin/end 与该方向对齐的 [LinearGradient]。
  ///
  /// [colors] and [stops] are forwarded to the gradient; callers typically
  /// shift [stops] each frame to animate the highlight.
  /// [colors] 与 [stops] 会传给渐变；调用方通常每帧平移 [stops] 以驱动高光动画。
  LinearGradient toGradient({
    required List<Color> colors,
    required List<double> stops,
  }) {
    final (Alignment begin, Alignment end) = _alignments;
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
  }

  /// The (begin, end) alignment pair for this direction.
  /// 该方向对应的 (begin, end) 对齐点。
  (Alignment, Alignment) get _alignments => switch (this) {
        FastShimmerDirection.leftToRight => (
            Alignment.centerLeft,
            Alignment.centerRight,
          ),
        FastShimmerDirection.rightToLeft => (
            Alignment.centerRight,
            Alignment.centerLeft,
          ),
        FastShimmerDirection.topToBottom => (
            Alignment.topCenter,
            Alignment.bottomCenter,
          ),
        FastShimmerDirection.bottomToTop => (
            Alignment.bottomCenter,
            Alignment.topCenter,
          ),
        FastShimmerDirection.diagonal => (
            Alignment.topLeft,
            Alignment.bottomRight,
          ),
      };

  /// The gradient begin alignment for this direction.
  /// 该方向渐变的起点对齐。
  Alignment get begin => _alignments.$1;

  /// The gradient end alignment for this direction.
  /// 该方向渐变的终点对齐。
  Alignment get end => _alignments.$2;
}
