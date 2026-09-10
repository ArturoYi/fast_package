import 'package:flutter/material.dart';

import '../fast_shimmer_direction.dart';
import '../fast_shimmer_scope.dart';
import '../fast_shimmer_theme.dart';

/// Sweeps a slanted soft sheen across **real** content (text, icons, thumbs).
/// 让一道斜向柔光扫过**真实**内容（文字、图标、滑块）。
///
/// This is the decorative counterpart of skeleton placeholders:
/// [FastShimmerText] draws empty bars; this widget tints existing glyphs
/// via [FastShimmerScope]'s [ShaderMask]. The beam only paints opaque
/// pixels — backgrounds behind the child stay still.
/// 这是骨架占位的装饰向对应物：[FastShimmerText] 画的是空心横条；
/// 本组件通过 [FastShimmerScope] 的 [ShaderMask] 给已有字形着色。
/// 光束只给不透明像素着色——子节点背后的背景保持不动。
///
/// Default motion matches a lock-screen hint: a ~3 s left-to-right sweep,
/// then a ~1.8 s pause before the next loop. Text color does **not** fade.
/// 默认动效对齐锁屏提示：约 3 秒从左扫到右，再停约 1.8 秒后循环。
/// 文字颜色**不会**随动画变浅。
///
/// [child] must paint **opaque** pixels (solid [Text] / [Icon] color). The
/// visible colors come from [FastShimmerTheme], not from the child's paint
/// color — `Colors.white` is a safe glyph color.
/// [child] 必须绘制**不透明**像素（实心 [Text] / [Icon] 颜色）。可见颜色来自
/// [FastShimmerTheme]，而不是子节点的绘制色——字形色用 `Colors.white` 最稳妥。
///
/// If an ancestor [FastShimmerScope] already exists, this widget only returns
/// [child] (no second [ShaderMask]). Color / timing overrides apply only
/// when this widget creates its own scope.
/// 若已有祖先 [FastShimmerScope]，则只返回 [child]（不再套第二层遮罩）。
/// 颜色 / 时序覆盖**仅**在本组件自己创建 Scope 时生效。
///
/// ```dart
/// FastShimmerHighlight.text(
///   '滑动解锁',
///   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
///   baseColor: Color(0x66FFFFFF),
///   highlightColor: Colors.white,
/// )
/// ```
class FastShimmerHighlight extends StatelessWidget {
  /// Sweep duration used when this widget creates a scope.
  /// 本组件自己创建 Scope 时的扫光时长。
  static const Duration defaultDuration = Duration(seconds: 3);

  /// Pause after the beam leaves the far edge.
  /// 光束离开远端边缘后的停顿。
  static const Duration defaultPauseDuration = Duration(milliseconds: 1800);

  /// Beam width as a fraction of the sweep axis.
  /// 高光带相对扫光轴的宽度比例。
  static const double defaultBandWidth = 0.18;

  /// Wraps [child] with a decorative beam sweep.
  /// 用装饰性光束扫光包裹 [child]。
  const FastShimmerHighlight({
    super.key,
    required this.child,
    this.duration,
    this.pauseDuration,
    this.bandWidth,
    this.baseColor,
    this.highlightColor,
    this.direction,
    this.sheenRotation,
  });

  /// Convenience for shimmer on a [Text] run.
  /// 给一段 [Text] 加上扫光的便捷构造。
  ///
  /// Forces an opaque white glyph color so the [ShaderMask] can paint the
  /// theme gradient. When [baseColor] is omitted, [style]'s `color` is used
  /// as the shimmer base (if present).
  /// 强制用不透明白色作为字形色，以便 [ShaderMask] 绘制主题渐变。
  /// 未传 [baseColor] 时，会把 [style] 的 `color` 当作扫光底色（若有）。
  factory FastShimmerHighlight.text(
    String data, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Duration? duration,
    Duration? pauseDuration,
    double? bandWidth,
    Color? baseColor,
    Color? highlightColor,
    FastShimmerDirection? direction,
    double? sheenRotation,
  }) {
    return FastShimmerHighlight(
      key: key,
      duration: duration,
      pauseDuration: pauseDuration,
      bandWidth: bandWidth,
      baseColor: baseColor ?? style?.color,
      highlightColor: highlightColor,
      direction: direction,
      sheenRotation: sheenRotation,
      child: Text(
        data,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ??
            (maxLines != null ? TextOverflow.ellipsis : null),
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }

  /// Opaque content that receives the highlight (typically [Text] or [Icon]).
  /// 接收扫光的不透明内容（通常是 [Text] 或 [Icon]）。
  final Widget child;

  /// Sweep length when this widget creates a [FastShimmerScope].
  /// 当本组件创建 [FastShimmerScope] 时的扫光时长。
  ///
  /// Ignored if an ancestor scope already exists. Defaults to [defaultDuration].
  /// 已有祖先 Scope 时忽略。默认 [defaultDuration]。
  final Duration? duration;

  /// Pause after the sweep. Defaults to [defaultPauseDuration].
  /// 扫完后的停顿。默认 [defaultPauseDuration]。
  final Duration? pauseDuration;

  /// Beam width fraction. Defaults to [defaultBandWidth].
  /// 高光带宽度比例。默认 [defaultBandWidth]。
  final double? bandWidth;

  /// Overrides [FastShimmerTheme.baseColor] for a locally created scope.
  /// 对本组件创建的 Scope 覆盖 [FastShimmerTheme.baseColor]。
  final Color? baseColor;

  /// Overrides [FastShimmerTheme.highlightColor] for a locally created scope.
  /// 对本组件创建的 Scope 覆盖 [FastShimmerTheme.highlightColor]。
  final Color? highlightColor;

  /// Overrides [FastShimmerTheme.direction] for a locally created scope.
  /// 对本组件创建的 Scope 覆盖 [FastShimmerTheme.direction]。
  final FastShimmerDirection? direction;

  /// Beam tilt in radians. `0` keeps a straight swipe. Defaults to
  /// [FastShimmerScope.beamSheenRotation] when this widget creates a scope.
  /// 光束倾斜（弧度）。`0` 为水平扫过。本组件创建 Scope 时默认
  /// [FastShimmerScope.beamSheenRotation]。
  final double? sheenRotation;

  @override
  Widget build(BuildContext context) {
    // Inherit the ancestor sweep so we never double-mask.
    // 复用祖先扫光，避免双重遮罩。
    if (FastShimmerScope.hasScope(context)) {
      return child;
    }

    final Duration sweepDuration = duration ?? defaultDuration;
    final Duration hold = pauseDuration ?? defaultPauseDuration;

    final FastShimmerTheme theme = FastShimmerTheme.resolve(
      context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: sweepDuration,
      direction: direction,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        extensions: <ThemeExtension<dynamic>>[theme],
      ),
      child: FastShimmerScope(
        duration: sweepDuration,
        pauseDuration: hold,
        sweep: FastShimmerSweep.beam,
        bandWidth: bandWidth ?? defaultBandWidth,
        sheenRotation:
            sheenRotation ?? FastShimmerScope.beamSheenRotation,
        child: child,
      ),
    );
  }
}
