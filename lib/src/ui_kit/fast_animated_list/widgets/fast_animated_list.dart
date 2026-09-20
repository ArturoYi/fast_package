import 'package:flutter/widgets.dart';

import '../animation/fast_animated_list_transition.dart';
import '../animation/fast_list_stagger.dart';
import '../controller/fast_animated_list_controller.dart';
import 'fast_list_core.dart';

/// Implicit list with insert / remove animation and first-frame stagger.
/// 隐式列表：增删动画 + 首屏错开入场。
class FastAnimatedList<T> extends StatelessWidget {
  /// Creates a vertical / horizontal animated list.
  /// 创建竖直 / 水平动画列表。
  const FastAnimatedList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    this.controller,
    this.stagger,
    this.entrance,
    this.transitionBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemExtent,
    this.insertDuration,
    this.removeDuration,
    this.slideOffset,
    this.animationBudget,
  }) : gridDelegate = null;

  /// Creates an animated grid.
  /// 创建动画网格。
  const FastAnimatedList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.stagger,
    this.entrance,
    this.transitionBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.insertDuration,
    this.removeDuration,
    this.slideOffset,
    this.animationBudget,
  }) : itemExtent = null;

  /// Current items.
  /// 当前数据。
  final List<T> items;

  /// Stable unique id.
  /// 稳定且唯一的 id。
  final FastListItemId<T> itemId;

  /// Row / cell builder.
  /// 行 / 格构建器。
  final FastListItemBuilder<T> itemBuilder;

  /// Optional observer. Caller disposes an external instance.
  /// 可选观察者。外部实例由调用方 dispose。
  final FastAnimatedListController? controller;

  /// First-frame and batch-insert stagger. Defaults to list / fixed-column grid.
  /// 首屏与批量插入错开。默认列表或固定列网格。
  final FastListStagger? stagger;

  /// Entrance recipe.
  /// 入场配方。
  final FastListEntrance? entrance;

  /// Custom insert / remove transition.
  /// 自定义增删过渡。
  final FastListTransitionBuilder? transitionBuilder;

  /// Grid delegate. Null for a list.
  /// 网格代理。列表时为 null。
  final SliverGridDelegate? gridDelegate;

  /// Scroll axis.
  /// 滚动轴。
  final Axis scrollDirection;

  /// Whether the scroll view is reversed.
  /// 是否反向滚动。
  final bool reverse;

  /// Scroll controller.
  /// 滚动控制器。
  final ScrollController? scrollController;

  /// Whether this is the primary scroll view.
  /// 是否主滚动视图。
  final bool? primary;

  /// Scroll physics.
  /// 滚动物理。
  final ScrollPhysics? physics;

  /// Whether the scroll view sizes itself to children.
  /// 是否按子节点收缩。
  final bool shrinkWrap;

  /// Viewport padding.
  /// 视口内边距。
  final EdgeInsetsGeometry? padding;

  /// Cache extent.
  /// 缓存范围。
  final double? cacheExtent;

  /// Keyboard dismiss behavior.
  /// 键盘收起行为。
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Restoration id.
  /// 还原 id。
  final String? restorationId;

  /// Clip behavior.
  /// 裁剪。
  final Clip clipBehavior;

  /// Fixed main-axis extent (list only).
  /// 主轴固定尺寸（仅列表）。
  final double? itemExtent;

  /// Insert duration override.
  /// 插入时长覆盖。
  final Duration? insertDuration;

  /// Remove duration override.
  /// 删除时长覆盖。
  final Duration? removeDuration;

  /// Slide offset override.
  /// 滑动位移覆盖。
  final double? slideOffset;

  /// Animation budget override.
  /// 动画条数预算覆盖。
  final int? animationBudget;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: true,
      enableReorder: false,
      sliver: false,
      controller: controller,
      stagger: stagger ?? defaultFastListStagger(gridDelegate),
      entrance: entrance,
      transitionBuilder: transitionBuilder,
      gridDelegate: gridDelegate,
      scrollDirection: scrollDirection,
      reverse: reverse,
      scrollController: scrollController,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      cacheExtent: cacheExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      itemExtent: itemExtent,
      insertDuration: insertDuration,
      removeDuration: removeDuration,
      slideOffset: slideOffset,
      animationBudget: animationBudget,
    );
  }
}

/// Sliver counterpart of [FastAnimatedList].
/// [FastAnimatedList] 的 sliver 版本。
class FastSliverAnimatedList<T> extends StatelessWidget {
  /// Creates an animated sliver list.
  /// 创建动画 sliver 列表。
  const FastSliverAnimatedList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    this.controller,
    this.stagger,
    this.entrance,
    this.transitionBuilder,
    this.padding,
    this.itemExtent,
    this.insertDuration,
    this.removeDuration,
    this.slideOffset,
    this.animationBudget,
  }) : gridDelegate = null;

  /// Creates an animated sliver grid.
  /// 创建动画 sliver 网格。
  const FastSliverAnimatedList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.stagger,
    this.entrance,
    this.transitionBuilder,
    this.padding,
    this.insertDuration,
    this.removeDuration,
    this.slideOffset,
    this.animationBudget,
  }) : itemExtent = null;

  /// Current items.
  /// 当前数据。
  final List<T> items;

  /// Stable unique id.
  /// 稳定且唯一的 id。
  final FastListItemId<T> itemId;

  /// Row / cell builder.
  /// 行 / 格构建器。
  final FastListItemBuilder<T> itemBuilder;

  /// Optional observer.
  /// 可选观察者。
  final FastAnimatedListController? controller;

  /// First-frame and batch-insert stagger.
  /// 首屏与批量插入错开。
  final FastListStagger? stagger;

  /// Entrance recipe.
  /// 入场配方。
  final FastListEntrance? entrance;

  /// Custom insert / remove transition.
  /// 自定义增删过渡。
  final FastListTransitionBuilder? transitionBuilder;

  /// Grid delegate. Null for a list.
  /// 网格代理。
  final SliverGridDelegate? gridDelegate;

  /// Sliver padding.
  /// sliver 内边距。
  final EdgeInsetsGeometry? padding;

  /// Fixed main-axis extent (list only).
  /// 主轴固定尺寸（仅列表）。
  final double? itemExtent;

  /// Insert duration override.
  /// 插入时长覆盖。
  final Duration? insertDuration;

  /// Remove duration override.
  /// 删除时长覆盖。
  final Duration? removeDuration;

  /// Slide offset override.
  /// 滑动位移覆盖。
  final double? slideOffset;

  /// Animation budget override.
  /// 动画条数预算覆盖。
  final int? animationBudget;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: true,
      enableReorder: false,
      sliver: true,
      controller: controller,
      stagger: stagger ?? defaultFastListStagger(gridDelegate),
      entrance: entrance,
      transitionBuilder: transitionBuilder,
      gridDelegate: gridDelegate,
      padding: padding,
      itemExtent: itemExtent,
      insertDuration: insertDuration,
      removeDuration: removeDuration,
      slideOffset: slideOffset,
      animationBudget: animationBudget,
    );
  }
}

/// Default stagger for a list or a fixed-column grid.
/// 列表或固定列网格的默认错开。
FastListStagger defaultFastListStagger(SliverGridDelegate? delegate) {
  if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
    return FastListStagger.grid(columnCount: delegate.crossAxisCount);
  }
  return const FastListStagger.list();
}
