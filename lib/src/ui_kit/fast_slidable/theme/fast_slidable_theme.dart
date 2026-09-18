import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A [ThemeExtension] for default [FastSlidable] motion and action chrome.
/// 用于 [FastSlidable] 默认动画与按钮外观的 [ThemeExtension]。
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
class FastSlidableTheme extends ThemeExtension<FastSlidableTheme> {
  /// Creates a slidable theme.
  /// 创建滑动主题。
  const FastSlidableTheme({
    required this.movementDuration,
    required this.movementCurve,
    required this.dismissDuration,
    required this.resizeDuration,
    required this.actionSpacing,
    required this.actionBorderRadius,
    required this.actionForegroundColor,
  });

  /// Open / close animation duration.
  /// 打开 / 关闭动画时长。
  final Duration movementDuration;

  /// Open / close animation curve.
  /// 打开 / 关闭动画曲线。
  final Curve movementCurve;

  /// Time to finish the swipe-away before resizing.
  /// 滑满后再收缩之前的时长。
  final Duration dismissDuration;

  /// Time to shrink the row after a dismiss.
  /// 删除后收缩行高的时长。
  final Duration resizeDuration;

  /// Gap between icon and label on [FastSlidableAction].
  /// [FastSlidableAction] 图标与文案间距。
  final double actionSpacing;

  /// Corner radius of action buttons.
  /// 操作按钮圆角。
  final double actionBorderRadius;

  /// Fallback foreground when an action does not set one.
  /// 操作未指定前景色时的回退色。
  final Color actionForegroundColor;

  /// Default light-mode theme.
  /// 亮色默认主题。
  static const FastSlidableTheme light = FastSlidableTheme(
    movementDuration: Duration(milliseconds: 200),
    movementCurve: Curves.ease,
    dismissDuration: Duration(milliseconds: 300),
    resizeDuration: Duration(milliseconds: 300),
    actionSpacing: 4,
    actionBorderRadius: 0,
    actionForegroundColor: Color(0xFFFFFFFF),
  );

  /// Default dark-mode theme.
  /// 暗色默认主题。
  static const FastSlidableTheme dark = FastSlidableTheme(
    movementDuration: Duration(milliseconds: 200),
    movementCurve: Curves.ease,
    dismissDuration: Duration(milliseconds: 300),
    resizeDuration: Duration(milliseconds: 300),
    actionSpacing: 4,
    actionBorderRadius: 0,
    actionForegroundColor: Color(0xFFFFFFFF),
  );

  /// Returns the extension from [context], or `null`.
  /// 从 [context] 读取扩展；不存在时为 `null`。
  static FastSlidableTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastSlidableTheme>();
  }

  /// Resolves the effective theme for [context].
  /// 解析 [context] 下的有效主题。
  static FastSlidableTheme resolve(
    BuildContext context, {
    Duration? movementDuration,
    Curve? movementCurve,
    Duration? dismissDuration,
    Duration? resizeDuration,
    double? actionSpacing,
    double? actionBorderRadius,
    Color? actionForegroundColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final FastSlidableTheme resolved = of(context) ??
        (theme.brightness == Brightness.dark ? dark : light);

    if (movementDuration == null &&
        movementCurve == null &&
        dismissDuration == null &&
        resizeDuration == null &&
        actionSpacing == null &&
        actionBorderRadius == null &&
        actionForegroundColor == null) {
      return resolved;
    }

    return resolved.copyWith(
      movementDuration: movementDuration,
      movementCurve: movementCurve,
      dismissDuration: dismissDuration,
      resizeDuration: resizeDuration,
      actionSpacing: actionSpacing,
      actionBorderRadius: actionBorderRadius,
      actionForegroundColor: actionForegroundColor,
    );
  }

  @override
  FastSlidableTheme copyWith({
    Duration? movementDuration,
    Curve? movementCurve,
    Duration? dismissDuration,
    Duration? resizeDuration,
    double? actionSpacing,
    double? actionBorderRadius,
    Color? actionForegroundColor,
  }) {
    return FastSlidableTheme(
      movementDuration: movementDuration ?? this.movementDuration,
      movementCurve: movementCurve ?? this.movementCurve,
      dismissDuration: dismissDuration ?? this.dismissDuration,
      resizeDuration: resizeDuration ?? this.resizeDuration,
      actionSpacing: actionSpacing ?? this.actionSpacing,
      actionBorderRadius: actionBorderRadius ?? this.actionBorderRadius,
      actionForegroundColor: actionForegroundColor ?? this.actionForegroundColor,
    );
  }

  @override
  FastSlidableTheme lerp(FastSlidableTheme? other, double t) {
    if (other == null) {
      return this;
    }
    return FastSlidableTheme(
      movementDuration: t < 0.5 ? movementDuration : other.movementDuration,
      movementCurve: t < 0.5 ? movementCurve : other.movementCurve,
      dismissDuration: t < 0.5 ? dismissDuration : other.dismissDuration,
      resizeDuration: t < 0.5 ? resizeDuration : other.resizeDuration,
      actionSpacing: lerpDouble(actionSpacing, other.actionSpacing, t)!,
      actionBorderRadius:
          lerpDouble(actionBorderRadius, other.actionBorderRadius, t)!,
      actionForegroundColor: Color.lerp(
        actionForegroundColor,
        other.actionForegroundColor,
        t,
      )!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FastSlidableTheme &&
        other.movementDuration == movementDuration &&
        other.movementCurve == movementCurve &&
        other.dismissDuration == dismissDuration &&
        other.resizeDuration == resizeDuration &&
        other.actionSpacing == actionSpacing &&
        other.actionBorderRadius == actionBorderRadius &&
        other.actionForegroundColor == actionForegroundColor;
  }

  @override
  int get hashCode => Object.hash(
        movementDuration,
        movementCurve,
        dismissDuration,
        resizeDuration,
        actionSpacing,
        actionBorderRadius,
        actionForegroundColor,
      );
}
