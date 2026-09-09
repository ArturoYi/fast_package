import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A [ThemeExtension] that styles the default [showLoading] panel and barrier.
/// 用于默认 Loading 面板与遮罩的 [ThemeExtension]。
///
/// Register it on [ThemeData.extensions] to apply app-wide defaults:
/// 将其注册到 [ThemeData.extensions] 即可应用全局默认值：
///
/// ```dart
/// ThemeData(
///   extensions: [FastLoadingTheme.light],
/// )
/// ```
///
/// Does **not** wrap [showLoading] content built by `builder`. The barrier
/// still uses this theme.
/// **不会**包裹 `builder` 自定义的 Loading 内容；遮罩仍走本主题。
///
/// Resolution order:
/// 1. Optional overrides passed to [resolve]
/// 2. [ThemeData] extension via [of] / [resolve]
/// 3. [light] or [dark] based on [ThemeData.brightness]
///
/// 解析优先级：
/// 1. 传给 [resolve] 的可选覆盖
/// 2. 通过 [of] / [resolve] 读取的 [ThemeData] 扩展
/// 3. 按 [ThemeData.brightness] 回退到 [light] 或 [dark]
class FastLoadingTheme extends ThemeExtension<FastLoadingTheme> {
  /// Creates a loading panel / barrier theme.
  /// 创建 Loading 面板与遮罩主题。
  const FastLoadingTheme({
    required this.backgroundColor,
    required this.indicatorColor,
    required this.textStyle,
    required this.borderRadius,
    required this.padding,
    required this.boxShadow,
    required this.barrierColor,
  });

  /// Panel background color.
  /// 面板背景色。
  final Color backgroundColor;

  /// [CircularProgressIndicator] color on the default panel.
  /// 默认面板上 [CircularProgressIndicator] 的颜色。
  final Color indicatorColor;

  /// Optional message text style.
  /// 可选文案的文字样式。
  final TextStyle textStyle;

  /// Corner radius of the panel.
  /// 面板圆角。
  final double borderRadius;

  /// Inner padding of the panel.
  /// 面板内边距。
  final EdgeInsets padding;

  /// Drop shadows that lift the panel off the page.
  /// 让面板从页面底色中浮出来的投影。
  final List<BoxShadow> boxShadow;

  /// Full-screen barrier color. Use a transparent color to dim without a tint.
  /// 全屏遮罩颜色；可用透明色只拦截点击、不染色。
  final Color barrierColor;

  /// Default light-mode loading theme.
  /// 亮色模式下的默认 Loading 主题。
  static const FastLoadingTheme light = FastLoadingTheme(
    backgroundColor: Color(0xE6222B45),
    indicatorColor: Color(0xFFFFFFFF),
    textStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
    borderRadius: 8,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x3D000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x29FFFFFF),
        blurRadius: 0,
        spreadRadius: 0.5,
      ),
    ],
    barrierColor: Color(0x33000000),
  );

  /// Default dark-mode loading theme.
  /// 暗色模式下的默认 Loading 主题。
  static const FastLoadingTheme dark = FastLoadingTheme(
    backgroundColor: Color(0xE6E8EAED),
    indicatorColor: Color(0xFF1A1A1A),
    textStyle: TextStyle(
      color: Color(0xFF1A1A1A),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
    borderRadius: 8,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x29000000),
        blurRadius: 0,
        spreadRadius: 0.5,
      ),
    ],
    barrierColor: Color(0x66000000),
  );

  /// Returns the [FastLoadingTheme] extension from [context], or `null`.
  /// 从 [context] 读取 [FastLoadingTheme] 扩展；若不存在则返回 `null`。
  static FastLoadingTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastLoadingTheme>();
  }

  /// Resolves the effective theme for [context].
  /// 解析 [context] 下的有效主题。
  ///
  /// Prefers a registered [ThemeExtension], otherwise falls back to [light]
  /// or [dark] based on [ThemeData.brightness].
  /// 优先使用已注册的 [ThemeExtension]；否则按 [ThemeData.brightness]
  /// 回退到 [light] 或 [dark]。
  static FastLoadingTheme resolve(
    BuildContext context, {
    Color? backgroundColor,
    Color? indicatorColor,
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
    Color? barrierColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final FastLoadingTheme resolved = of(context) ??
        (theme.brightness == Brightness.dark ? dark : light);

    if (backgroundColor == null &&
        indicatorColor == null &&
        textStyle == null &&
        borderRadius == null &&
        padding == null &&
        boxShadow == null &&
        barrierColor == null) {
      return resolved;
    }

    return resolved.copyWith(
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      textStyle: textStyle,
      borderRadius: borderRadius,
      padding: padding,
      boxShadow: boxShadow,
      barrierColor: barrierColor,
    );
  }

  /// Creates a copy with the given fields replaced.
  /// 创建一份替换了指定字段的副本。
  @override
  FastLoadingTheme copyWith({
    Color? backgroundColor,
    Color? indicatorColor,
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
    Color? barrierColor,
  }) {
    return FastLoadingTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      boxShadow: boxShadow ?? this.boxShadow,
      barrierColor: barrierColor ?? this.barrierColor,
    );
  }

  /// Linearly interpolates between this theme and [other].
  /// 在本主题与 [other] 之间做线性插值。
  @override
  FastLoadingTheme lerp(FastLoadingTheme? other, double t) {
    if (other == null) return this;
    return FastLoadingTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      boxShadow:
          BoxShadow.lerpList(boxShadow, other.boxShadow, t) ?? boxShadow,
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastLoadingTheme &&
        other.backgroundColor == backgroundColor &&
        other.indicatorColor == indicatorColor &&
        other.textStyle == textStyle &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        listEquals(other.boxShadow, boxShadow) &&
        other.barrierColor == barrierColor;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        indicatorColor,
        textStyle,
        borderRadius,
        padding,
        Object.hashAll(boxShadow),
        barrierColor,
      );
}
