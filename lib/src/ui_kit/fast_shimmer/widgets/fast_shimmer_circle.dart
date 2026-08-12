import 'package:flutter/material.dart';

import '../fast_shimmer_direction.dart';
import '../fast_shimmer_scope.dart';
import '../fast_shimmer_theme.dart';

/// An animated shimmer circle placeholder.
/// 圆形 shimmer 占位组件。
///
/// **Inside a [FastShimmerScope]** (recommended): renders a solid white circle
/// tinted by the parent [ShaderMask].
/// **位于 [FastShimmerScope] 内**（推荐）：绘制纯白圆形，由父级 [ShaderMask] 着色。
///
/// **Standalone**: renders a static circle filled with [baseColor].
/// **独立使用**：绘制填充 [baseColor] 的静态圆形。
///
/// ```dart
/// FastShimmerScope(
///   child: Row(
///     children: [
///       FastShimmerCircle(diameter: 48),
///       SizedBox(width: 12),
///       FastShimmerText(lines: 2, width: 160),
///     ],
///   ),
/// )
/// ```
class FastShimmerCircle extends StatelessWidget {
  /// Creates a circular shimmer placeholder with the given [diameter].
  /// 使用给定 [diameter] 创建一个圆形 shimmer 占位。
  const FastShimmerCircle({
    super.key,
    required this.diameter,
    this.baseColor,
    this.highlightColor,
    this.direction,
  });

  /// Diameter of the circle in logical pixels.
  /// 圆形直径（逻辑像素）。
  final double diameter;

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
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _resolveFillColor(context, baseColor: baseColor),
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
