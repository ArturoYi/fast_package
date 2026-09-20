import 'package:flutter/widgets.dart';

import '../animation/fast_animated_list_transition.dart';
import '../animation/fast_list_stagger.dart';
import '../controller/fast_animated_list_controller.dart';
import '../drag/fast_list_drag_coordinator.dart';
import 'fast_list_core.dart';
import 'fast_animated_list.dart';

/// Insert / remove animation plus drag reorder.
/// 增删动画 + 拖拽排序入口。
class FastAnimatedReorderableList<T> extends StatelessWidget {
  /// Creates an animated reorderable list.
  /// 创建可排序动画列表。
  const FastAnimatedReorderableList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    this.controller,
    this.stagger,
    this.entrance,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
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
    this.reorderDuration,
    this.slideOffset,
    this.animationBudget,
    this.dragEnabled = true,
  }) : gridDelegate = null;

  /// Creates an animated reorderable grid.
  /// 创建可排序动画网格。
  const FastAnimatedReorderableList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    required this.gridDelegate,
    this.controller,
    this.stagger,
    this.entrance,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
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
    this.reorderDuration,
    this.slideOffset,
    this.animationBudget,
    this.dragEnabled = true,
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

  /// Flutter-style reorder callback (`newIndex -= 1` when `oldIndex < newIndex`).
  /// 对齐 Flutter 的排序回调（`oldIndex < newIndex` 时先 `newIndex -= 1`）。
  final ReorderCallback onReorder;

  /// Optional observer. Caller disposes an external instance.
  /// 可选观察者。外部实例由调用方 dispose。
  final FastAnimatedListController? controller;

  /// First-frame and batch-insert stagger.
  /// 首屏与批量插入错开。
  final FastListStagger? stagger;

  /// Entrance recipe.
  /// 入场配方。
  final FastListEntrance? entrance;

  /// How a drag starts.
  /// 拖拽如何开始。
  final FastListDragTrigger dragTrigger;

  /// Overlay proxy wrapper.
  /// 拖拽代理包装。
  final FastListProxyBuilder<T>? proxyBuilder;

  /// Custom insert / remove transition.
  /// 自定义增删过渡。
  final FastListTransitionBuilder? transitionBuilder;

  /// Grid delegate. Null for a list.
  /// 网格代理。
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

  /// Sibling shift duration override.
  /// 兄弟让位时长覆盖。
  final Duration? reorderDuration;

  /// Slide offset override.
  /// 滑动位移覆盖。
  final double? slideOffset;

  /// Animation budget override.
  /// 动画条数预算覆盖。
  final int? animationBudget;

  /// Whether drag is enabled.
  /// 是否允许拖拽。
  final bool dragEnabled;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: true,
      enableReorder: true,
      sliver: false,
      onReorder: onReorder,
      controller: controller,
      stagger: stagger ?? defaultFastListStagger(gridDelegate),
      entrance: entrance,
      dragTrigger: dragTrigger,
      proxyBuilder: proxyBuilder,
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
      reorderDuration: reorderDuration,
      slideOffset: slideOffset,
      animationBudget: animationBudget,
      dragEnabled: dragEnabled,
    );
  }
}

/// Sliver counterpart of [FastAnimatedReorderableList].
/// [FastAnimatedReorderableList] 的 sliver 版本。
class FastSliverAnimatedReorderableList<T> extends StatelessWidget {
  /// Creates an animated reorderable sliver list.
  /// 创建可排序动画 sliver 列表。
  const FastSliverAnimatedReorderableList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    this.controller,
    this.stagger,
    this.entrance,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
    this.transitionBuilder,
    this.padding,
    this.itemExtent,
    this.insertDuration,
    this.removeDuration,
    this.reorderDuration,
    this.slideOffset,
    this.animationBudget,
    this.dragEnabled = true,
  }) : gridDelegate = null;

  /// Creates an animated reorderable sliver grid.
  /// 创建可排序动画 sliver 网格。
  const FastSliverAnimatedReorderableList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    required this.gridDelegate,
    this.controller,
    this.stagger,
    this.entrance,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
    this.transitionBuilder,
    this.padding,
    this.insertDuration,
    this.removeDuration,
    this.reorderDuration,
    this.slideOffset,
    this.animationBudget,
    this.dragEnabled = true,
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

  /// Flutter-style reorder callback.
  /// 对齐 Flutter 的排序回调。
  final ReorderCallback onReorder;

  /// Optional observer.
  /// 可选观察者。
  final FastAnimatedListController? controller;

  /// First-frame and batch-insert stagger.
  /// 首屏与批量插入错开。
  final FastListStagger? stagger;

  /// Entrance recipe.
  /// 入场配方。
  final FastListEntrance? entrance;

  /// How a drag starts.
  /// 拖拽如何开始。
  final FastListDragTrigger dragTrigger;

  /// Overlay proxy wrapper.
  /// 拖拽代理包装。
  final FastListProxyBuilder<T>? proxyBuilder;

  /// Custom insert / remove transition.
  /// 自定义增删过渡。
  final FastListTransitionBuilder? transitionBuilder;

  /// Grid delegate.
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

  /// Sibling shift duration override.
  /// 兄弟让位时长覆盖。
  final Duration? reorderDuration;

  /// Slide offset override.
  /// 滑动位移覆盖。
  final double? slideOffset;

  /// Animation budget override.
  /// 动画条数预算覆盖。
  final int? animationBudget;

  /// Whether drag is enabled.
  /// 是否允许拖拽。
  final bool dragEnabled;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: true,
      enableReorder: true,
      sliver: true,
      onReorder: onReorder,
      controller: controller,
      stagger: stagger ?? defaultFastListStagger(gridDelegate),
      entrance: entrance,
      dragTrigger: dragTrigger,
      proxyBuilder: proxyBuilder,
      transitionBuilder: transitionBuilder,
      gridDelegate: gridDelegate,
      padding: padding,
      itemExtent: itemExtent,
      insertDuration: insertDuration,
      removeDuration: removeDuration,
      reorderDuration: reorderDuration,
      slideOffset: slideOffset,
      animationBudget: animationBudget,
      dragEnabled: dragEnabled,
    );
  }
}
