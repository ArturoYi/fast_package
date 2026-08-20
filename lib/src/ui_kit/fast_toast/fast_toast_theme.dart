import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A [ThemeExtension] that styles the default [showToast] text panel.
/// 用于默认文本 Toast 面板的 [ThemeExtension]。
///
/// Register it on [ThemeData.extensions] to apply app-wide defaults:
/// 将其注册到 [ThemeData.extensions] 即可应用全局默认值：
///
/// ```dart
/// ThemeData(
///   extensions: [FastToastTheme.light],
/// )
/// ```
///
/// Does **not** wrap [showCustomToast] content.
/// **不会**包裹 [showCustomToast] 的内容。
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
class FastToastTheme extends ThemeExtension<FastToastTheme> {
  /// Creates a toast text-panel theme.
  /// 创建文本 Toast 面板主题。
  const FastToastTheme({
    required this.backgroundColor,
    required this.textStyle,
    required this.borderRadius,
    required this.padding,
    required this.boxShadow,
  });

  /// Panel background color.
  /// 面板背景色。
  final Color backgroundColor;

  /// Message text style.
  /// 文案文字样式。
  final TextStyle textStyle;

  /// Corner radius of the panel.
  /// 面板圆角。
  final double borderRadius;

  /// Inner padding of the panel.
  /// 面板内边距。
  final EdgeInsets padding;

  /// Drop shadows that lift the panel off the page.
  /// 让面板从页面底色中浮出来的投影。
  ///
  /// Light defaults pair a dark drop shadow with a light rim for dark panels.
  /// Dark defaults use a stronger dark shadow and rim for light panels.
  /// 亮色默认：深色下落阴影 + 浅色描边，配合深色面板。
  /// 暗色默认：更深的下落阴影 + 深色描边，配合浅色面板。
  final List<BoxShadow> boxShadow;

  /// Default light-mode toast theme.
  /// 亮色模式下的默认 Toast 主题。
  static const FastToastTheme light = FastToastTheme(
    backgroundColor: Color(0xE6222B45),
    textStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
    borderRadius: 8,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
  );

  /// Default dark-mode toast theme.
  /// 暗色模式下的默认 Toast 主题。
  static const FastToastTheme dark = FastToastTheme(
    backgroundColor: Color(0xE6E8EAED),
    textStyle: TextStyle(
      color: Color(0xFF1A1A1A),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
    borderRadius: 8,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
  );

  /// Returns the [FastToastTheme] extension from [context], or `null`.
  /// 从 [context] 读取 [FastToastTheme] 扩展；若不存在则返回 `null`。
  static FastToastTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastToastTheme>();
  }

  /// Resolves the effective theme for [context].
  /// 解析 [context] 下的有效主题。
  ///
  /// Prefers a registered [ThemeExtension], otherwise falls back to [light]
  /// or [dark] based on [ThemeData.brightness].
  /// 优先使用已注册的 [ThemeExtension]；否则按 [ThemeData.brightness]
  /// 回退到 [light] 或 [dark]。
  static FastToastTheme resolve(
    BuildContext context, {
    Color? backgroundColor,
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
  }) {
    final ThemeData theme = Theme.of(context);
    final FastToastTheme resolved = of(context) ??
        (theme.brightness == Brightness.dark ? dark : light);

    if (backgroundColor == null &&
        textStyle == null &&
        borderRadius == null &&
        padding == null &&
        boxShadow == null) {
      return resolved;
    }

    return resolved.copyWith(
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      borderRadius: borderRadius,
      padding: padding,
      boxShadow: boxShadow,
    );
  }

  /// Creates a copy with the given fields replaced.
  /// 创建一份替换了指定字段的副本。
  @override
  FastToastTheme copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    double? borderRadius,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
  }) {
    return FastToastTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }

  /// Linearly interpolates between this theme and [other].
  /// 在本主题与 [other] 之间做线性插值。
  @override
  FastToastTheme lerp(FastToastTheme? other, double t) {
    if (other == null) return this;
    return FastToastTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      boxShadow:
          BoxShadow.lerpList(boxShadow, other.boxShadow, t) ?? boxShadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastToastTheme &&
        other.backgroundColor == backgroundColor &&
        other.textStyle == textStyle &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        listEquals(other.boxShadow, boxShadow);
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        textStyle,
        borderRadius,
        padding,
        Object.hashAll(boxShadow),
      );
}
