import 'package:flutter/material.dart';

import '../fast_shimmer_direction.dart';
import '../fast_shimmer_scope.dart';
import '../fast_shimmer_theme.dart';

/// An animated shimmer text placeholder — stacked bars that mimic a paragraph.
/// 文字行 shimmer 占位——用堆叠横条模拟段落。
///
/// **Inside a [FastShimmerScope]** (recommended): renders solid white bars
/// tinted by the parent [ShaderMask].
/// **位于 [FastShimmerScope] 内**（推荐）：绘制纯白横条，由父级 [ShaderMask] 着色。
///
/// **Standalone**: renders static bars filled with [baseColor].
/// **独立使用**：绘制填充 [baseColor] 的静态横条。
///
/// The last line is shortened to [lastLineWidthFraction] of [width] to look
/// more like real paragraph text.
/// 最后一行缩短为 [width] 的 [lastLineWidthFraction]，更接近真实段落。
///
/// ```dart
/// FastShimmerScope(
///   child: FastShimmerText(lines: 3, width: 240),
/// )
/// ```
class FastShimmerText extends StatelessWidget {
  /// Creates a multi-line text shimmer placeholder.
  /// 创建一个多行文字 shimmer 占位。
  const FastShimmerText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12.0,
    this.lineSpacing = 6.0,
    this.lastLineWidthFraction = 0.6,
    this.width = 200.0,
    this.baseColor,
    this.highlightColor,
    this.direction,
  });

  /// Number of horizontal bars to render. Must be at least 1.
  /// 要绘制的横条数量，至少为 1。
  final int lines;

  /// Height of each bar in logical pixels.
  /// 每条横条的高度（逻辑像素）。
  final double lineHeight;

  /// Vertical gap between bars.
  /// 横条之间的垂直间距。
  final double lineSpacing;

  /// Width fraction (`0`–`1`) of the last line relative to [width].
  /// 最后一行相对 [width] 的宽度比例（`0`–`1`）。
  final double lastLineWidthFraction;

  /// Full width of non-last lines in logical pixels.
  /// 非末行横条的完整宽度（逻辑像素）。
  final double width;

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
    assert(lines >= 1, 'lines must be at least 1');
    assert(
      lastLineWidthFraction > 0 && lastLineWidthFraction <= 1,
      'lastLineWidthFraction must be in (0, 1]',
    );

    final Color fill = _resolveFillColor(context, baseColor: baseColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(lines, (int index) {
        final bool isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : lineSpacing),
          child: Container(
            width: isLast ? width * lastLineWidthFraction : width,
            height: lineHeight,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
        );
      }),
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
