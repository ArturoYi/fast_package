import 'package:flutter/material.dart';

import '../fast_shimmer_direction.dart';
import '../fast_shimmer_scope.dart';
import '../fast_shimmer_theme.dart';

/// An animated shimmer rectangle placeholder.
/// 矩形 shimmer 占位组件。
///
/// **Inside a [FastShimmerScope]** (recommended): renders a solid white box.
/// The parent scope applies the animated gradient via [ShaderMask] — no
/// per-frame rebuild cost, and perfectly in sync with sibling placeholders.
/// **位于 [FastShimmerScope] 内**（推荐）：绘制纯白矩形。父级 Scope 通过
/// [ShaderMask] 套上动画渐变——无每帧重建成本，并与兄弟占位完美同步。
///
/// **Standalone** (no scope ancestor): renders a static placeholder filled
/// with [baseColor] (or the resolved theme base color).
/// **独立使用**（无 Scope 祖先）：绘制填充 [baseColor]（或主题底色）的静态占位。
///
/// ```dart
/// FastShimmerScope(
///   child: Column(
///     children: [
///       FastShimmerBox(width: double.infinity, height: 180),
///       SizedBox(height: 12),
///       FastShimmerBox(
///         width: 200,
///         height: 16,
///         borderRadius: BorderRadius.circular(4),
///       ),
///     ],
///   ),
/// )
/// ```
class FastShimmerBox extends StatelessWidget {
  /// Creates a rectangular shimmer placeholder.
  /// 创建一个矩形 shimmer 占位。
  const FastShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
    this.baseColor,
    this.highlightColor,
    this.direction,
  });

  /// Width of the rectangle in logical pixels.
  /// 矩形宽度（逻辑像素）。
  final double width;

  /// Height of the rectangle in logical pixels.
  /// 矩形高度（逻辑像素）。
  final double height;

  /// Corner radii. Defaults to sharp corners.
  /// 圆角半径，默认为直角。
  final BorderRadius borderRadius;

  /// Overrides [FastShimmerTheme.baseColor] in standalone mode only.
  /// 仅在独立模式下覆盖 [FastShimmerTheme.baseColor]。
  final Color? baseColor;

  /// Reserved for API consistency; unused inside a [FastShimmerScope].
  /// 为 API 一致性保留；在 [FastShimmerScope] 内不使用。
  final Color? highlightColor;

  /// Reserved for API consistency; unused inside a [FastShimmerScope].
  /// 为 API 一致性保留；在 [FastShimmerScope] 内不使用。
  final FastShimmerDirection? direction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // White under ShaderMask; theme/base color when standalone.
        // ShaderMask 下用白色；独立使用时用主题/自定义底色。
        color: _resolveFillColor(context, baseColor: baseColor),
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Resolves placeholder fill: white inside scope, otherwise theme/base color.
/// 解析占位填充色：Scope 内为白色，否则为主题/自定义底色。
Color _resolveFillColor(BuildContext context, {Color? baseColor}) {
  if (FastShimmerScope.hasScope(context)) {
    return Colors.white;
  }
  return baseColor ?? FastShimmerTheme.resolve(context).baseColor;
}
