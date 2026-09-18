import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../fast_refresh/fast_refresh.dart';
import '../animation/fast_animated_list_transition.dart';
import '../animation/fast_list_diff.dart';
import '../animation/fast_list_stagger.dart';
import '../controller/fast_animated_composite_list_controller.dart';
import '../drag/fast_list_drag_coordinator.dart';
import '../drag/fast_list_geometry.dart';
import '../theme/fast_animated_composite_list_theme.dart';

/// Builds a row / cell from [item].
/// 用 [item] 构建一行 / 一格。
typedef FastListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// Identity of [item]. Must be unique and stable.
/// [item] 的 identity，必须稳定且唯一。
typedef FastListItemId<T> = Object Function(T item);

/// Wraps the default insert / remove transition.
/// 包一层默认增删过渡。
typedef FastListTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

/// Wraps the drag overlay proxy.
/// 包一层拖拽代理。
typedef FastListProxyBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  Widget child,
);

/// Shared host for animated / reorderable / composite lists.
/// 增删、拖拽、组合列表的共享宿主。
class FastListCore<T> extends StatefulWidget {
  /// Creates the shared host.
  /// 创建共享宿主。
  const FastListCore({
    super.key,
    required this.items,
    required this.itemId,
    required this.itemBuilder,
    required this.animateMutations,
    required this.enableReorder,
    required this.sliver,
    this.onReorder,
    this.controller,
    this.stagger = const FastListStagger.list(),
    this.entrance,
    this.dragTrigger = FastListDragTrigger.longPress,
    this.proxyBuilder,
    this.transitionBuilder,
    this.gridDelegate,
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
  });

  /// Current items. The parent owns this list.
  /// 当前数据。由调用方持有。
  final List<T> items;

  /// Stable unique id.
  /// 稳定且唯一的 id。
  final FastListItemId<T> itemId;

  /// Row / cell builder.
  /// 行 / 格构建器。
  final FastListItemBuilder<T> itemBuilder;

  /// Whether insert / remove should animate.
  /// 增删是否动画。
  final bool animateMutations;

  /// Whether drag reorder is enabled at the capability level.
  /// 能力层是否启用拖拽排序。
  final bool enableReorder;

  /// Whether this widget is a sliver.
  /// 是否作为 sliver。
  final bool sliver;

  /// Flutter-style reorder callback.
  /// 对齐 Flutter 的排序回调。
  final ReorderCallback? onReorder;

  /// Optional observer. Caller disposes an external instance.
  /// 可选观察者。外部实例由调用方 dispose。
  final FastAnimatedCompositeListController? controller;

  /// First-frame stagger.
  /// 首屏错开。
  final FastListStagger stagger;

  /// Entrance recipe override.
  /// 入场配方覆盖。
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

  /// Non-null when this is a grid.
  /// 网格时非空。
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

  /// Fixed extent along the main axis (lists only).
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

  /// Runtime switch for drag (Refresh lock also flips this).
  /// 运行时是否允许拖（Refresh 锁也会关掉）。
  final bool dragEnabled;

  @override
  State<FastListCore<T>> createState() => _FastListCoreState<T>();
}

class _FastListCoreState<T> extends State<FastListCore<T>>
    with TickerProviderStateMixin {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  final GlobalKey<SliverAnimatedGridState> _gridKey =
      GlobalKey<SliverAnimatedGridState>();

  final FastListGeometry _geometry = FastListGeometry();
  final FastListDragCoordinator _drag = FastListDragCoordinator();
  final ValueNotifier<Offset> _proxyOffset = ValueNotifier<Offset>(Offset.zero);

  late List<Object> _ids;
  late Map<Object, T> _dataById;
  late AnimationController _staggerController;

  FastAnimatedCompositeListController? _ownedController;
  OverlayEntry? _overlayEntry;
  Ticker? _scrollTicker;
  Timer? _animTimer;
  FastRefreshData? _refresh;
  bool _limitNewItems = false;
  bool _refreshLocked = false;
  bool _proxyVisible = false;
  Offset _lastGlobal = Offset.zero;
  Offset _grabOffset = Offset.zero;
  double _scrollVelocity = 0;

  FastAnimatedCompositeListController get _effectiveController {
    return widget.controller ?? _ownedController!;
  }

  bool get _isGrid => widget.gridDelegate != null;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = FastAnimatedCompositeListController();
    }
    _ids = widget.items.map(widget.itemId).toList();
    debugAssertUniqueItemIds(_ids);
    _dataById = <Object, T>{
      for (final T item in widget.items) widget.itemId(item): item,
    };
    _staggerController = AnimationController(
      vsync: this,
      duration: widget.stagger.isEnabled
          ? widget.stagger.totalDuration
          : const Duration(milliseconds: 1),
    );
    if (widget.stagger.isEnabled && _ids.isNotEmpty) {
      _staggerController.forward();
    } else {
      _staggerController.value = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _limitNewItems = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unbindRefresh();
    _refresh = FastRefresh.maybeOf(context);
    _bindRefresh();
    _syncRefreshLock();
  }

  @override
  void didUpdateWidget(covariant FastListCore<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        final FastAnimatedCompositeListController? owned = _ownedController;
        _ownedController = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          owned?.dispose();
        });
      }
      if (widget.controller == null) {
        _ownedController = FastAnimatedCompositeListController();
      }
    }
    _syncItems(widget.items);
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    _scrollTicker?.dispose();
    _hideProxy();
    _unbindRefresh();
    _staggerController.dispose();
    _proxyOffset.dispose();
    _drag.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _bindRefresh() {
    _refresh?.userOffsetNotifier.addListener(_syncRefreshLock);
    _refresh?.headerNotifier.addModeChangeListener(_onRefreshMode);
    _refresh?.footerNotifier.addModeChangeListener(_onRefreshMode);
  }

  void _unbindRefresh() {
    _refresh?.userOffsetNotifier.removeListener(_syncRefreshLock);
    _refresh?.headerNotifier.removeModeChangeListener(_onRefreshMode);
    _refresh?.footerNotifier.removeModeChangeListener(_onRefreshMode);
    _refresh = null;
  }

  void _onRefreshMode(FastRefreshMode mode, double offset) {
    _syncRefreshLock();
  }

  void _syncRefreshLock() {
    final FastRefreshData? data = _refresh;
    final bool next = data != null &&
        (data.userOffsetNotifier.value ||
            data.headerNotifier.mode != FastRefreshMode.inactive ||
            data.footerNotifier.mode != FastRefreshMode.inactive);
    if (next == _refreshLocked) {
      return;
    }
    _refreshLocked = next;
    if (next && _drag.isDragging) {
      _endDrag(cancel: true);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _syncItems(List<T> items) {
    final List<Object> newIds = items.map(widget.itemId).toList();
    debugAssertUniqueItemIds(newIds);
    final Map<Object, T> newData = <Object, T>{
      for (final T item in items) widget.itemId(item): item,
    };

    if (listEquals(_ids, newIds)) {
      _dataById = newData;
      return;
    }

    if (_drag.isDragging) {
      if (listEquals(_ids, newIds)) {
        _dataById = newData;
        return;
      }
      _endDrag(cancel: true);
    }

    final FastAnimatedCompositeListTheme theme = _themeOf();
    if (!widget.animateMutations) {
      _snapTo(newIds, newData);
      return;
    }

    final FastListDiff diff = FastListDiffer(
      animationBudget: widget.animationBudget ?? theme.animationBudget,
    ).compute(_ids, newIds);

    if (diff.reset) {
      _snapTo(newIds, newData);
      return;
    }

    Duration maxDuration = Duration.zero;
    for (final FastListOp op in diff.ops) {
      switch (op) {
        case FastListRemoveOp(:final int index):
          final Duration duration = theme.removeDuration;
          _applyRemove(index, duration);
          if (duration > maxDuration) {
            maxDuration = duration;
          }
        case FastListInsertOp(:final int index, :final Object id):
          final T? item = newData[id];
          if (item != null) {
            _dataById[id] = item;
          }
          _ids.insert(index, id);
          final Duration duration =
              widget.insertDuration ?? theme.insertDuration;
          _insertItem(index, duration);
          if (duration > maxDuration) {
            maxDuration = duration;
          }
        case FastListMoveOp(:final int from, :final int to):
          _applyMove(from, to);
      }
    }
    _dataById = newData;
    _markAnimating(maxDuration);
  }

  FastAnimatedCompositeListTheme _themeOf() {
    return FastAnimatedCompositeListTheme.resolve(
      context,
      insertDuration: widget.insertDuration,
      removeDuration: widget.removeDuration,
      reorderDuration: widget.reorderDuration,
      entrance: widget.entrance,
      slideOffset: widget.slideOffset,
      animationBudget: widget.animationBudget,
    );
  }

  void _snapTo(List<Object> newIds, Map<Object, T> newData) {
    for (int i = _ids.length - 1; i >= 0; i--) {
      _removeItem(
        i,
        (BuildContext context, Animation<double> animation) =>
            const SizedBox.shrink(),
        Duration.zero,
      );
    }
    _ids
      ..clear()
      ..addAll(newIds);
    _dataById = newData;
    for (int i = 0; i < newIds.length; i++) {
      _insertItem(i, Duration.zero);
    }
    _markAnimating(Duration.zero);
  }

  void _applyRemove(int index, Duration duration) {
    final Object id = _ids.removeAt(index);
    final T? data = _dataById[id];
    _removeItem(index, (BuildContext context, Animation<double> animation) {
      if (data == null) {
        return const SizedBox.shrink();
      }
      return _buildDecorated(
        context: context,
        item: data,
        id: id,
        index: index,
        animation: animation,
        interactive: false,
      );
    }, duration);
  }

  void _applyMove(int from, int to) {
    final Object id = _ids.removeAt(from);
    _ids.insert(to, id);
    _removeItem(
      from,
      (BuildContext context, Animation<double> animation) =>
          const SizedBox.shrink(),
      Duration.zero,
    );
    _insertItem(to, Duration.zero);
  }

  void _insertItem(int index, Duration duration) {
    if (_isGrid) {
      _gridKey.currentState?.insertItem(index, duration: duration);
    } else {
      _listKey.currentState?.insertItem(index, duration: duration);
    }
  }

  void _removeItem(
    int index,
    AnimatedRemovedItemBuilder builder,
    Duration duration,
  ) {
    if (_isGrid) {
      _gridKey.currentState?.removeItem(index, builder, duration: duration);
    } else {
      _listKey.currentState?.removeItem(index, builder, duration: duration);
    }
  }

  void _markAnimating(Duration duration) {
    if (duration == Duration.zero) {
      _effectiveController.setAnimating(false);
      return;
    }
    _effectiveController.setAnimating(true);
    _animTimer?.cancel();
    _animTimer = Timer(duration + const Duration(milliseconds: 32), () {
      if (mounted) {
        _effectiveController.setAnimating(false);
      }
    });
  }

  int? _findChildIndex(Key key) {
    if (key is! ValueKey) {
      return null;
    }
    final Object? value = key.value;
    if (value == null) {
      return null;
    }
    final int index = _ids.indexOf(value);
    return index < 0 ? null : index;
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    if (index < 0 || index >= _ids.length) {
      return const SizedBox.shrink();
    }
    final Object id = _ids[index];
    final T? item = _dataById[id];
    if (item == null) {
      return const SizedBox.shrink();
    }
    return _buildDecorated(
      context: context,
      item: item,
      id: id,
      index: index,
      animation: animation,
      interactive: true,
    );
  }

  Widget _buildDecorated({
    required BuildContext context,
    required T item,
    required Object id,
    required int index,
    required Animation<double> animation,
    required bool interactive,
  }) {
    final FastAnimatedCompositeListTheme theme = _themeOf();
    final FastListEntrance entrance = widget.entrance ?? theme.entrance;
    final double slideOffset = widget.slideOffset ?? theme.slideOffset;

    Widget child = widget.itemBuilder(context, item, index);
    if (widget.itemExtent != null && !_isGrid) {
      child = widget.scrollDirection == Axis.vertical
          ? SizedBox(height: widget.itemExtent, child: child)
          : SizedBox(width: widget.itemExtent, child: child);
    }
    child = RepaintBoundary(child: child);

    if (widget.transitionBuilder != null) {
      child = widget.transitionBuilder!(context, child, animation);
    } else if (widget.animateMutations) {
      child = FastListMutationTransition(
        animation: animation,
        axis: widget.scrollDirection,
        grid: _isGrid,
        entrance: entrance,
        curve: interactive ? theme.insertCurve : theme.removeCurve,
        slideOffset: slideOffset,
        child: child,
      );
    }

    child = FastListStaggerSlot(
      position: index,
      entrance: entrance,
      slideOffset: slideOffset,
      child: child,
    );

    child = _FastListSlot(
      id: id,
      index: index,
      geometry: _geometry,
      coordinator: _drag,
      ids: _ids,
      reorderDuration: widget.reorderDuration ?? theme.reorderDuration,
      dragTrigger: widget.dragTrigger,
      longPressDuration: theme.longPressDuration,
      canDrag: interactive &&
          widget.enableReorder &&
          widget.dragEnabled &&
          widget.onReorder != null &&
          !_refreshLocked,
      onDragStart: _startDrag,
      onDragUpdate: _updateDrag,
      onDragEnd: _endDrag,
      child: child,
    );

    return KeyedSubtree(
      key: ValueKey<Object>(id),
      child: child,
    );
  }

  bool get _dragAllowed {
    return widget.enableReorder &&
        widget.dragEnabled &&
        widget.onReorder != null &&
        !_refreshLocked;
  }

  void _startDrag(int index, Offset global) {
    if (!_dragAllowed || _drag.isDragging) {
      return;
    }
    if (index < 0 || index >= _ids.length) {
      return;
    }
    final Object id = _ids[index];
    final Size resolvedSize = _geometry.sizeOf(id) ??
        Size(
          widget.scrollDirection == Axis.vertical
              ? 400
              : (widget.itemExtent ?? 56),
          widget.scrollDirection == Axis.vertical
              ? (widget.itemExtent ?? 56)
              : 400,
        );
    final Offset resolvedOrigin = _geometry.globalOrigin(id) ??
        global - Offset(24, resolvedSize.height / 2);
    _lastGlobal = global;
    _grabOffset = global - resolvedOrigin;
    _proxyOffset.value = global - _grabOffset;
    _drag.start(index: index, id: id, size: resolvedSize);
    _effectiveController.setDragging(true);
    _showProxy(index, id);
  }

  void _updateDrag(Offset global) {
    if (!_drag.isDragging) {
      return;
    }
    _lastGlobal = global;
    _proxyOffset.value = global - _grabOffset;
    _drag.updateHover(_resolveHover(global));
    _updateAutoScroll(global);
  }

  int _resolveHover(Offset global) {
    final int fallback = _drag.dragIndex ?? 0;
    if (_geometry.hasAnyBox(_ids)) {
      return _geometry.hoverAt(global, _ids, fallback);
    }
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    final RenderObject? renderObject = scrollable?.context.findRenderObject();
    if (scrollable == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return fallback;
    }
    final Offset local = renderObject.globalToLocal(global);
    final double extent = widget.scrollDirection == Axis.vertical
        ? (_drag.draggedSize.height > 0
            ? _drag.draggedSize.height
            : (widget.itemExtent ?? 56))
        : (_drag.draggedSize.width > 0
            ? _drag.draggedSize.width
            : (widget.itemExtent ?? 56));
    if (extent <= 0) {
      return fallback;
    }
    final double along = scrollable.position.pixels +
        (widget.scrollDirection == Axis.vertical ? local.dy : local.dx);
    return (along / extent).floor().clamp(0, _ids.length - 1);
  }

  void _endDrag({bool cancel = false}) {
    if (!_drag.isDragging) {
      return;
    }
    _scrollTicker?.stop();
    _scrollVelocity = 0;
    final int from = _drag.dragIndex!;
    final int hover = _drag.hoverIndex!;
    if (!cancel && from != hover) {
      final Object id = _ids.removeAt(from);
      _ids.insert(hover, id);
      _removeItem(
        from,
        (BuildContext context, Animation<double> animation) =>
            const SizedBox.shrink(),
        Duration.zero,
      );
      _insertItem(hover, Duration.zero);
    }
    _hideProxy();
    _drag.end();
    _effectiveController.setDragging(false);
    if (!cancel && from != hover) {
      widget.onReorder!(from, from < hover ? hover + 1 : hover);
    }
  }

  void _showProxy(int index, Object id) {
    final T? item = _dataById[id];
    if (item == null) {
      return;
    }
    final FastAnimatedCompositeListTheme theme = _themeOf();
    Widget proxy = widget.itemBuilder(context, item, index);
    if (widget.proxyBuilder != null) {
      proxy = widget.proxyBuilder!(context, item, index, proxy);
    } else {
      proxy = Material(
        elevation: theme.dragElevation,
        color: Colors.transparent,
        shadowColor: const Color(0x42000000),
        child: proxy,
      );
    }
    _hideProxy();
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _FastListDragProxy(
          offsetListenable: _proxyOffset,
          size: _drag.draggedSize,
          child: proxy,
        );
      },
    );
    Overlay.of(context, rootOverlay: true, debugRequiredFor: widget)
        .insert(_overlayEntry!);
    _proxyVisible = true;
  }

  void _hideProxy() {
    if (!_proxyVisible && _overlayEntry == null) {
      return;
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _proxyVisible = false;
  }

  void _updateAutoScroll(Offset global) {
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    final RenderObject? renderObject = scrollable?.context.findRenderObject();
    if (scrollable == null ||
        renderObject is! RenderBox ||
        !renderObject.hasSize) {
      return;
    }
    final FastAnimatedCompositeListTheme theme = _themeOf();
    final Offset local = renderObject.globalToLocal(global);
    final Size size = renderObject.size;
    final double edge = theme.autoScrollEdge;
    double delta = 0;
    if (widget.scrollDirection == Axis.vertical) {
      if (local.dy < edge) {
        delta = local.dy - edge;
      } else if (local.dy > size.height - edge) {
        delta = local.dy - (size.height - edge);
      }
    } else if (local.dx < edge) {
      delta = local.dx - edge;
    } else if (local.dx > size.width - edge) {
      delta = local.dx - (size.width - edge);
    }
    _scrollVelocity = delta * 0.12;
    if (_scrollVelocity == 0) {
      _scrollTicker?.stop();
      return;
    }
    _scrollTicker ??= createTicker(_onScrollTick);
    if (!_scrollTicker!.isActive) {
      _scrollTicker!.start();
    }
  }

  void _onScrollTick(Duration elapsed) {
    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (position == null || _scrollVelocity == 0 || !_drag.isDragging) {
      _scrollTicker?.stop();
      return;
    }
    final double next = (position.pixels + _scrollVelocity)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next != position.pixels) {
      position.jumpTo(next);
    }
    _drag.updateHover(_resolveHover(_lastGlobal));
    _proxyOffset.value = _lastGlobal - _grabOffset;
  }

  @override
  Widget build(BuildContext context) {
    assert(!widget.enableReorder || widget.onReorder != null);
    final Widget sliver = FastStaggerScope(
      animation: _staggerController,
      stagger: widget.stagger,
      limitNewItems: _limitNewItems,
      child: _isGrid
          ? SliverAnimatedGrid(
              key: _gridKey,
              gridDelegate: widget.gridDelegate!,
              itemBuilder: _itemBuilder,
              initialItemCount: _ids.length,
              findChildIndexCallback: _findChildIndex,
            )
          : SliverAnimatedList(
              key: _listKey,
              itemBuilder: _itemBuilder,
              initialItemCount: _ids.length,
              findChildIndexCallback: _findChildIndex,
            ),
    );

    final Widget padded = widget.padding == null
        ? sliver
        : SliverPadding(padding: widget.padding!, sliver: sliver);

    if (widget.sliver) {
      return padded;
    }

    return CustomScrollView(
      controller: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      // scrollCacheExtent is 3.41+; package floor is Flutter 3.19.6.
      // ignore: deprecated_member_use
      cacheExtent: widget.cacheExtent,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[padded],
    );
  }
}

class _FastListSlot extends StatefulWidget {
  const _FastListSlot({
    required this.id,
    required this.index,
    required this.geometry,
    required this.coordinator,
    required this.ids,
    required this.reorderDuration,
    required this.dragTrigger,
    required this.longPressDuration,
    required this.canDrag,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final Object id;
  final int index;
  final FastListGeometry geometry;
  final FastListDragCoordinator coordinator;
  final List<Object> ids;
  final Duration reorderDuration;
  final FastListDragTrigger dragTrigger;
  final Duration longPressDuration;
  final bool canDrag;
  final void Function(int index, Offset global) onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final void Function({bool cancel}) onDragEnd;
  final Widget child;

  @override
  State<_FastListSlot> createState() => _FastListSlotState();
}

class _FastListSlotState extends State<_FastListSlot>
    implements FastListSlotHandle {
  final GlobalKey _boxKey = GlobalKey();

  @override
  RenderBox? get renderBox {
    final RenderObject? object = _boxKey.currentContext?.findRenderObject();
    return object is RenderBox ? object : null;
  }

  @override
  void initState() {
    super.initState();
    widget.geometry.register(widget.id, this);
  }

  @override
  void didUpdateWidget(covariant _FastListSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      widget.geometry.unregister(oldWidget.id, this);
    }
    widget.geometry.register(widget.id, this);
  }

  @override
  void dispose() {
    widget.geometry.unregister(widget.id, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ListenableBuilder(
      listenable: widget.coordinator,
      builder: (BuildContext context, Widget? child) {
        final bool hidden = widget.coordinator.dragId == widget.id;
        final Offset shift = widget.coordinator.shiftFor(
          index: widget.index,
          ids: widget.ids,
          geometry: widget.geometry,
        );
        return _ShiftedBox(
          offset: hidden ? Offset.zero : shift,
          duration: widget.coordinator.isDragging
              ? widget.reorderDuration
              : Duration.zero,
          child: Opacity(
            opacity: hidden ? 0 : 1,
            child: child,
          ),
        );
      },
      child: widget.child,
    );

    child = FastListItemDragScope(
      index: widget.index,
      enabled: widget.canDrag,
      trigger: widget.dragTrigger,
      onDragStart: widget.onDragStart,
      onDragUpdate: widget.onDragUpdate,
      onDragEnd: (bool cancel) => widget.onDragEnd(cancel: cancel),
      child: child,
    );

    if (widget.canDrag && widget.dragTrigger == FastListDragTrigger.longPress) {
      child = RawGestureDetector(
        behavior: HitTestBehavior.deferToChild,
        gestures: <Type, GestureRecognizerFactory>{
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(
              duration: widget.longPressDuration,
              debugOwner: this,
            ),
            (LongPressGestureRecognizer instance) {
              instance
                ..onLongPressStart = (LongPressStartDetails details) {
                  widget.onDragStart(widget.index, details.globalPosition);
                }
                ..onLongPressMoveUpdate = (LongPressMoveUpdateDetails details) {
                  widget.onDragUpdate(details.globalPosition);
                }
                ..onLongPressEnd = (_) {
                  widget.onDragEnd(cancel: false);
                }
                ..onLongPressCancel = () {
                  widget.onDragEnd(cancel: true);
                };
            },
          ),
        },
        child: child,
      );
    }

    return KeyedSubtree(key: _boxKey, child: child);
  }
}

class _ShiftedBox extends StatelessWidget {
  const _ShiftedBox({
    required this.offset,
    required this.duration,
    required this.child,
  });

  final Offset offset;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(end: offset),
      duration: duration,
      curve: Curves.easeOut,
      builder: (BuildContext context, Offset value, Widget? child) {
        return Transform.translate(offset: value, child: child);
      },
      child: child,
    );
  }
}

class _FastListDragProxy extends StatelessWidget {
  const _FastListDragProxy({
    required this.offsetListenable,
    required this.size,
    required this.child,
  });

  final ValueNotifier<Offset> offsetListenable;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<Offset>(
        valueListenable: offsetListenable,
        builder: (BuildContext context, Offset offset, Widget? child) {
          return Stack(
            children: <Widget>[
              Positioned(
                left: offset.dx,
                top: offset.dy,
                width: size.width,
                height: size.height,
                child: child!,
              ),
            ],
          );
        },
        child: child,
      ),
    );
  }
}
