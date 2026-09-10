import 'dart:math' as math;

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

  /// A thin band [Rect] that travels along this direction.
  /// 沿该方向移动的细高光带矩形。
  ///
  /// [t] is `0` (just off the start edge) through `1` (just off the end edge).
  /// [bandWidth] is the band size as a fraction of the sweep-axis length.
  /// [t] 为 `0`（刚离开起点外侧）到 `1`（刚离开终点外侧）。
  /// [bandWidth] 是高光带相对扫光轴长度的比例。
  Rect travelingBand(
    Rect bounds, {
    required double t,
    required double bandWidth,
  }) {
    final double progress = t.clamp(0.0, 1.0);
    final double fraction = bandWidth.clamp(0.02, 1.0);

    switch (this) {
      case FastShimmerDirection.leftToRight:
      case FastShimmerDirection.rightToLeft:
        final double band = math.max(bounds.width * fraction, 8.0);
        final double along = this == FastShimmerDirection.leftToRight
            ? progress
            : 1.0 - progress;
        return Rect.fromLTWH(
          -band + (bounds.width + band) * along,
          0,
          band,
          bounds.height,
        );
      case FastShimmerDirection.topToBottom:
      case FastShimmerDirection.bottomToTop:
        final double band = math.max(bounds.height * fraction, 8.0);
        final double along = this == FastShimmerDirection.topToBottom
            ? progress
            : 1.0 - progress;
        return Rect.fromLTWH(
          0,
          -band + (bounds.height + band) * along,
          bounds.width,
          band,
        );
      case FastShimmerDirection.diagonal:
        final double bandW = math.max(bounds.width * fraction, 8.0);
        final double bandH = math.max(bounds.height * fraction, 8.0);
        return Rect.fromLTWH(
          -bandW + (bounds.width + bandW) * progress,
          -bandH + (bounds.height + bandH) * progress,
          bandW,
          bandH,
        );
    }
  }
}
