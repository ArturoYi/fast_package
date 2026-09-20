import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../animation/fast_animated_list_transition.dart';

/// A [ThemeExtension] for default list motion.
/// 列表默认动画的 [ThemeExtension]。
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
class FastAnimatedListTheme extends ThemeExtension<FastAnimatedListTheme> {
  /// Creates a list theme.
  /// 创建列表主题。
  const FastAnimatedListTheme({
    required this.insertDuration,
    required this.removeDuration,
    required this.reorderDuration,
    required this.insertCurve,
    required this.removeCurve,
    required this.entrance,
    required this.slideOffset,
    required this.animationBudget,
    required this.dragElevation,
    required this.longPressDuration,
    required this.autoScrollEdge,
  });

  /// Insert animation duration.
  /// 插入动画时长。
  final Duration insertDuration;

  /// Remove animation duration.
  /// 删除动画时长。
  final Duration removeDuration;

  /// Sibling gap animation while dragging.
  /// 拖拽时兄弟项让位动画时长。
  final Duration reorderDuration;

  /// Insert curve.
  /// 插入曲线。
  final Curve insertCurve;

  /// Remove curve.
  /// 删除曲线。
  final Curve removeCurve;

  /// Default entrance recipe.
  /// 默认入场配方。
  final FastListEntrance entrance;

  /// Slide pixels for slide / fadeSlide.
  /// slide / fadeSlide 的像素位移。
  final double slideOffset;

  /// Max animated insert+remove ops before a snap.
  /// 超过该增删次数则整表对齐。
  final int animationBudget;

  /// Overlay proxy elevation.
  /// 拖拽代理阴影。
  final double dragElevation;

  /// Long-press duration before a drag starts.
  /// 长按多久后开始拖拽。
  final Duration longPressDuration;

  /// Edge thickness that triggers auto-scroll while dragging.
  /// 拖拽时触发自动滚动的边缘厚度。
  final double autoScrollEdge;

  /// Default light-mode theme.
  /// 亮色默认主题。
  static const FastAnimatedListTheme light = FastAnimatedListTheme(
    insertDuration: Duration(milliseconds: 225),
    removeDuration: Duration(milliseconds: 225),
    reorderDuration: Duration(milliseconds: 180),
    insertCurve: Curves.easeOut,
    removeCurve: Curves.easeIn,
    entrance: FastListEntrance.fadeSlide,
    slideOffset: 50,
    animationBudget: 24,
    dragElevation: 8,
    longPressDuration: Duration(milliseconds: 400),
    autoScrollEdge: 56,
  );

  /// Default dark-mode theme.
  /// 暗色默认主题。
  static const FastAnimatedListTheme dark = light;

  /// Returns the extension from [context], or `null`.
  /// 从 [context] 读取扩展；不存在时为 `null`。
  static FastAnimatedListTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastAnimatedListTheme>();
  }

  /// Resolves the effective theme for [context].
  /// 解析 [context] 下的有效主题。
  static FastAnimatedListTheme resolve(
    BuildContext context, {
    Duration? insertDuration,
    Duration? removeDuration,
    Duration? reorderDuration,
    Curve? insertCurve,
    Curve? removeCurve,
    FastListEntrance? entrance,
    double? slideOffset,
    int? animationBudget,
    double? dragElevation,
    Duration? longPressDuration,
    double? autoScrollEdge,
  }) {
    final ThemeData theme = Theme.of(context);
    final FastAnimatedListTheme resolved =
        of(context) ?? (theme.brightness == Brightness.dark ? dark : light);

    if (insertDuration == null &&
        removeDuration == null &&
        reorderDuration == null &&
        insertCurve == null &&
        removeCurve == null &&
        entrance == null &&
        slideOffset == null &&
        animationBudget == null &&
        dragElevation == null &&
        longPressDuration == null &&
        autoScrollEdge == null) {
      return resolved;
    }

    return resolved.copyWith(
      insertDuration: insertDuration,
      removeDuration: removeDuration,
      reorderDuration: reorderDuration,
      insertCurve: insertCurve,
      removeCurve: removeCurve,
      entrance: entrance,
      slideOffset: slideOffset,
      animationBudget: animationBudget,
      dragElevation: dragElevation,
      longPressDuration: longPressDuration,
      autoScrollEdge: autoScrollEdge,
    );
  }

  @override
  FastAnimatedListTheme copyWith({
    Duration? insertDuration,
    Duration? removeDuration,
    Duration? reorderDuration,
    Curve? insertCurve,
    Curve? removeCurve,
    FastListEntrance? entrance,
    double? slideOffset,
    int? animationBudget,
    double? dragElevation,
    Duration? longPressDuration,
    double? autoScrollEdge,
  }) {
    return FastAnimatedListTheme(
      insertDuration: insertDuration ?? this.insertDuration,
      removeDuration: removeDuration ?? this.removeDuration,
      reorderDuration: reorderDuration ?? this.reorderDuration,
      insertCurve: insertCurve ?? this.insertCurve,
      removeCurve: removeCurve ?? this.removeCurve,
      entrance: entrance ?? this.entrance,
      slideOffset: slideOffset ?? this.slideOffset,
      animationBudget: animationBudget ?? this.animationBudget,
      dragElevation: dragElevation ?? this.dragElevation,
      longPressDuration: longPressDuration ?? this.longPressDuration,
      autoScrollEdge: autoScrollEdge ?? this.autoScrollEdge,
    );
  }

  @override
  FastAnimatedListTheme lerp(
    FastAnimatedListTheme? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return FastAnimatedListTheme(
      insertDuration: t < 0.5 ? insertDuration : other.insertDuration,
      removeDuration: t < 0.5 ? removeDuration : other.removeDuration,
      reorderDuration: t < 0.5 ? reorderDuration : other.reorderDuration,
      insertCurve: t < 0.5 ? insertCurve : other.insertCurve,
      removeCurve: t < 0.5 ? removeCurve : other.removeCurve,
      entrance: t < 0.5 ? entrance : other.entrance,
      slideOffset: lerpDouble(slideOffset, other.slideOffset, t)!,
      animationBudget: t < 0.5 ? animationBudget : other.animationBudget,
      dragElevation: lerpDouble(dragElevation, other.dragElevation, t)!,
      longPressDuration: t < 0.5 ? longPressDuration : other.longPressDuration,
      autoScrollEdge: lerpDouble(autoScrollEdge, other.autoScrollEdge, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FastAnimatedListTheme &&
        other.insertDuration == insertDuration &&
        other.removeDuration == removeDuration &&
        other.reorderDuration == reorderDuration &&
        other.insertCurve == insertCurve &&
        other.removeCurve == removeCurve &&
        other.entrance == entrance &&
        other.slideOffset == slideOffset &&
        other.animationBudget == animationBudget &&
        other.dragElevation == dragElevation &&
        other.longPressDuration == longPressDuration &&
        other.autoScrollEdge == autoScrollEdge;
  }

  @override
  int get hashCode => Object.hash(
        insertDuration,
        removeDuration,
        reorderDuration,
        insertCurve,
        removeCurve,
        entrance,
        slideOffset,
        animationBudget,
        dragElevation,
        longPressDuration,
        autoScrollEdge,
      );
}
