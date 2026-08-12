import 'package:flutter/material.dart';

import 'fast_shimmer_direction.dart';

/// A [ThemeExtension] that controls the visual appearance of shimmer widgets.
/// 一个控制 shimmer 组件视觉表现的 [ThemeExtension]。
///
/// Register it on [ThemeData.extensions] to apply app-wide defaults:
/// 将其注册到 [ThemeData.extensions] 即可应用全局默认值：
///
/// ```dart
/// ThemeData(
///   extensions: [FastShimmerTheme.light],
/// )
/// ```
///
/// Resolution order used by shimmer widgets:
/// 1. Explicit widget constructor overrides (e.g. `baseColor`)
/// 2. [ThemeData] extension via [of] / [resolve]
/// 3. [light] or [dark] based on [ThemeData.brightness]
///
/// shimmer 组件的主题解析优先级：
/// 1. 组件构造参数显式覆盖（例如 `baseColor`）
/// 2. 通过 [of] / [resolve] 读取的 [ThemeData] 扩展
/// 3. 按 [ThemeData.brightness] 回退到 [light] 或 [dark]
class FastShimmerTheme extends ThemeExtension<FastShimmerTheme> {
  /// Creates a shimmer theme with the given visual parameters.
  /// 使用给定的视觉参数创建 shimmer 主题。
  const FastShimmerTheme({
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
    required this.direction,
  });

  /// The base (background) color of the shimmer.
  /// shimmer 的底色（背景色）。
  final Color baseColor;

  /// The bright highlight color that travels across the shimmer.
  /// 扫过 shimmer 表面的高光颜色。
  final Color highlightColor;

  /// How long one full shimmer cycle takes.
  /// 完成一次完整扫光循环所需时长。
  final Duration duration;

  /// The direction the highlight travels.
  /// 高光扫过的方向。
  final FastShimmerDirection direction;

  /// Default light-mode shimmer theme.
  /// 亮色模式下的默认 shimmer 主题。
  static const FastShimmerTheme light = FastShimmerTheme(
    baseColor: Color(0xFFE0E0E0),
    highlightColor: Color(0xFFF5F5F5),
    duration: Duration(milliseconds: 1500),
    direction: FastShimmerDirection.leftToRight,
  );

  /// Default dark-mode shimmer theme.
  /// 暗色模式下的默认 shimmer 主题。
  static const FastShimmerTheme dark = FastShimmerTheme(
    baseColor: Color(0xFF2C2C2C),
    highlightColor: Color(0xFF3D3D3D),
    duration: Duration(milliseconds: 1500),
    direction: FastShimmerDirection.leftToRight,
  );

  /// Returns the [FastShimmerTheme] extension from [context], or `null`.
  /// 从 [context] 读取 [FastShimmerTheme] 扩展；若不存在则返回 `null`。
  static FastShimmerTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastShimmerTheme>();
  }

  /// Resolves the effective theme for [context].
  /// 解析 [context] 下的有效主题。
  ///
  /// Prefers a registered [ThemeExtension], otherwise falls back to [light]
  /// or [dark] based on [ThemeData.brightness].
  /// 优先使用已注册的 [ThemeExtension]；否则按 [ThemeData.brightness]
  /// 回退到 [light] 或 [dark]。
  ///
  /// Optional overrides replace individual fields after resolution.
  /// 可选覆盖参数会在解析完成后替换对应字段。
  static FastShimmerTheme resolve(
    BuildContext context, {
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
    FastShimmerDirection? direction,
  }) {
    final ThemeData theme = Theme.of(context);
    final FastShimmerTheme resolved = of(context) ??
        (theme.brightness == Brightness.dark ? dark : light);

    if (baseColor == null &&
        highlightColor == null &&
        duration == null &&
        direction == null) {
      return resolved;
    }

    return resolved.copyWith(
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      direction: direction,
    );
  }

  /// Creates a copy with the given fields replaced.
  /// 创建一份替换了指定字段的副本。
  @override
  FastShimmerTheme copyWith({
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
    FastShimmerDirection? direction,
  }) {
    return FastShimmerTheme(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
      duration: duration ?? this.duration,
      direction: direction ?? this.direction,
    );
  }

  /// Linearly interpolates between this theme and [other].
  /// 在本主题与 [other] 之间做线性插值。
  ///
  /// [direction] switches at `t == 0.5` because it is discrete.
  /// [direction] 为离散值，在 `t == 0.5` 处切换。
  @override
  FastShimmerTheme lerp(FastShimmerTheme? other, double t) {
    if (other == null) return this;
    return FastShimmerTheme(
      baseColor: Color.lerp(baseColor, other.baseColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      duration: Duration(
        microseconds: (duration.inMicroseconds +
                (other.duration.inMicroseconds - duration.inMicroseconds) * t)
            .round(),
      ),
      direction: t < 0.5 ? direction : other.direction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastShimmerTheme &&
        other.baseColor == baseColor &&
        other.highlightColor == highlightColor &&
        other.duration == duration &&
        other.direction == direction;
  }

  @override
  int get hashCode =>
      Object.hash(baseColor, highlightColor, duration, direction);
}
