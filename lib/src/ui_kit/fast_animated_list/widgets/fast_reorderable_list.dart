import 'package:flutter/widgets.dart';

import '../animation/fast_list_stagger.dart';
import '../controller/fast_animated_list_controller.dart';
import '../drag/fast_list_drag_coordinator.dart';
import 'fast_list_core.dart';

/// Drag-to-reorder list without insert / remove animation.
/// 只做拖拽排序、不做增删动画的列表。
class FastReorderableList<T> extends StatelessWidget {
  /// Creates a reorderable list.
  /// 创建可排序列表。
  const FastReorderableList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    this.controller,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
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
    this.reorderDuration,
    this.dragEnabled = true,
  }) : gridDelegate = null;

  /// Creates a reorderable grid.
  /// 创建可排序网格。
  const FastReorderableList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    required this.gridDelegate,
    this.controller,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
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
    this.reorderDuration,
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

  /// Optional observer.
  /// 可选观察者。
  final FastAnimatedListController? controller;

  /// How a drag starts.
  /// 拖拽如何开始。
  final FastListDragTrigger dragTrigger;

  /// Overlay proxy wrapper.
  /// 拖拽代理包装。
  final FastListProxyBuilder<T>? proxyBuilder;

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

  /// Sibling shift duration override.
  /// 兄弟让位时长覆盖。
  final Duration? reorderDuration;

  /// Whether drag is enabled.
  /// 是否允许拖拽。
  final bool dragEnabled;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: false,
      enableReorder: true,
      sliver: false,
      onReorder: onReorder,
      controller: controller,
      stagger: const FastListStagger.none(),
      dragTrigger: dragTrigger,
      proxyBuilder: proxyBuilder,
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
      reorderDuration: reorderDuration,
      dragEnabled: dragEnabled,
    );
  }
}

/// Sliver counterpart of [FastReorderableList].
/// [FastReorderableList] 的 sliver 版本。
class FastSliverReorderableList<T> extends StatelessWidget {
  /// Creates a reorderable sliver list.
  /// 创建可排序 sliver 列表。
  const FastSliverReorderableList({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    this.controller,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
    this.padding,
    this.itemExtent,
    this.reorderDuration,
    this.dragEnabled = true,
  }) : gridDelegate = null;

  /// Creates a reorderable sliver grid.
  /// 创建可排序 sliver 网格。
  const FastSliverReorderableList.grid({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.onReorder,
    required this.gridDelegate,
    this.controller,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
    this.padding,
    this.reorderDuration,
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

  /// How a drag starts.
  /// 拖拽如何开始。
  final FastListDragTrigger dragTrigger;

  /// Overlay proxy wrapper.
  /// 拖拽代理包装。
  final FastListProxyBuilder<T>? proxyBuilder;

  /// Grid delegate.
  /// 网格代理。
  final SliverGridDelegate? gridDelegate;

  /// Sliver padding.
  /// sliver 内边距。
  final EdgeInsetsGeometry? padding;

  /// Fixed main-axis extent (list only).
  /// 主轴固定尺寸（仅列表）。
  final double? itemExtent;

  /// Sibling shift duration override.
  /// 兄弟让位时长覆盖。
  final Duration? reorderDuration;

  /// Whether drag is enabled.
  /// 是否允许拖拽。
  final bool dragEnabled;

  @override
  Widget build(BuildContext context) {
    return FastListCore<T>(
      items: items,
      itemId: itemId,
      itemBuilder: itemBuilder,
      animateMutations: false,
      enableReorder: true,
      sliver: true,
      onReorder: onReorder,
      controller: controller,
      stagger: const FastListStagger.none(),
      dragTrigger: dragTrigger,
      proxyBuilder: proxyBuilder,
      gridDelegate: gridDelegate,
      padding: padding,
      itemExtent: itemExtent,
      reorderDuration: reorderDuration,
      dragEnabled: dragEnabled,
    );
  }
}
