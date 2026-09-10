part of 'fast_refresh.dart';

/// [FastPaging] 的列表项构建器。
typedef FastPagingItemBuilder<ItemType> = Widget Function(
  BuildContext context,
  int index,
  ItemType item,
);

/// 基于 [FastRefresh] 的分页列表基类。
///
/// 对齐 EasyRefresh 配套的 `EasyPaging`：子类只维护 [data] / 页码 / 总数，
/// 刷新与加载的生命周期、空态、`noMore` 由本类接到 [FastRefresh]。
///
/// 默认走 [FastRefresh.builder]（[useDefaultPhysics] 为 `false`），把 physics
/// 挂到内部 [CustomScrollView]。单列表且没有嵌套滚动时，可设
/// [useDefaultPhysics] 为 `true`，改用 Widget 构造注入物理。
abstract class FastPaging<DataType, ItemType> extends StatefulWidget {
  /// 为 `true` 时用 [FastRefresh] Widget 构造；为 `false` 时用
  /// [FastRefresh.builder]。
  final bool useDefaultPhysics;

  /// 可选的编程控制器。未传时由 State 自行创建并释放。
  final FastRefreshController? controller;

  /// [onRefresh] 为 `null` 时的越界行为，不构建可见组件。
  final FastNotRefreshHeader? notRefreshHeader;

  /// [onLoad] 为 `null` 时的越界行为，不构建可见组件。
  final FastNotLoadFooter? notLoadFooter;

  /// Header / Footer 未单独指定弹簧时使用的回弹弹簧。
  final physics.SpringDescription? spring;

  /// 越界摩擦。
  final FastRefreshFrictionFactor? frictionFactor;

  /// 为 `true` 时刷新与加载可同时进行；默认互斥。
  final bool simultaneously;

  /// Header 结果为 [FastRefreshResult.noMore] 后是否仍允许刷新。
  final bool canRefreshAfterNoMore;

  /// Footer 结果为 [FastRefreshResult.noMore] 后是否仍允许加载。
  final bool canLoadAfterNoMore;

  /// 刷新成功后是否重置 Footer 的 `noMore`。
  final bool resetAfterRefresh;

  /// 首帧构建完成后自动触发刷新。
  final bool refreshOnStart;

  /// [FastRefreshController.callRefresh] / [refreshOnStart] 多拉出的距离。
  final double callRefreshOverOffset;

  /// [FastRefreshController.callLoad] 多拉出的距离。
  final double callLoadOverOffset;

  /// 见 [Stack.fit]。
  final StackFit fit;

  /// 见 [Stack.clipBehavior]。
  final Clip clipBehavior;

  /// 滚动行为工厂。
  final FastRefreshScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// 无法从 [ScrollMetrics] 拿到 [ScrollPosition] 时用于编程滚动。
  final ScrollController? scrollController;

  /// 只在该轴上展示指示器并执行任务；`null` 表示不限制。
  final Axis? triggerAxis;

  /// 为 `true` 时按 NestedScrollView 处理内外层。
  final bool isNested;

  /// 列表项构建器。子类也可直接覆写 [FastPagingState.buildItem]。
  final FastPagingItemBuilder<ItemType>? itemBuilder;

  /// [refreshOnStart] 期间的占位。
  final WidgetBuilder? refreshOnStartWidgetBuilder;

  /// [FastPagingState.isEmpty] 时的占位。
  final WidgetBuilder? emptyWidgetBuilder;

  /// 创建分页列表。
  const FastPaging({
    super.key,
    this.useDefaultPhysics = false,
    this.controller,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
    this.itemBuilder,
    this.refreshOnStartWidgetBuilder,
    this.emptyWidgetBuilder,
  })  : assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  @override
  FastPagingState<DataType, ItemType, FastPaging<DataType, ItemType>>
      createState();
}

/// [FastPaging] 的状态：维护数据、页码，并接到 [FastRefresh]。
abstract class FastPagingState<DataType, ItemType,
        PagingWidget extends FastPaging<DataType, ItemType>>
    extends State<PagingWidget> {
  /// 当前已加载的数据。尚未请求成功时为 `null`。
  DataType? data;

  /// 总页数。与 [page] 一起用于 [isNoMore]；也可只提供 [total]。
  int? get totalPage;

  /// 当前页码。
  int? get page;

  /// 全部条目数。优先于 [page] / [totalPage] 判断 [isNoMore]。
  int? get total;

  /// 当前已展示的条目数。
  int get count;

  /// 取第 [index] 条。调用方保证 [index] 合法。
  ItemType getItem(int index);

  /// 已有数据且条目数为 0。
  bool get isEmpty => data != null && count == 0;

  /// 已加载完全部数据。
  ///
  /// 优先用 [total]（`count >= total`）；否则用 [page] / [totalPage]。
  /// [data] 仍为 `null` 时视为还有更多。
  bool get isNoMore {
    if (data == null) {
      return false;
    }
    if (total != null) {
      return count >= total!;
    }
    if (page != null && totalPage != null) {
      return page! >= totalPage!;
    }
    return false;
  }

  /// 是否启用下拉刷新。为 `false` 时不传 [FastRefresh.onRefresh]。
  bool get enableRefresh => true;

  /// 是否启用上拉 / 触底加载。为 `false` 时不传 [FastRefresh.onLoad]。
  bool get enableLoad => true;

  /// 刷新回调。子类在这里重置 [data] / 页码。
  ///
  /// 可返回 [FastRefreshResult]；`null` 表示由本类根据 [isNoMore] 收尾。
  FutureOr<FastRefreshResult?> onRefresh() => null;

  Future<FastRefreshResult?> _onRefresh() async {
    final FastRefreshResult? result = await onRefresh();
    if (!_refreshController.controlFinishRefresh && isNoMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshController.finishLoad(FastRefreshResult.noMore, true);
        }
      });
    }
    if (result is FastRefreshResult) {
      return result;
    }
    return null;
  }

  /// 加载回调。子类在这里追加 [data]。
  ///
  /// 可返回 [FastRefreshResult]；`null` 时本类按 [isNoMore] 返回
  /// [FastRefreshResult.noMore] 或 [FastRefreshResult.success]。
  FutureOr<FastRefreshResult?> onLoad() => null;

  Future<FastRefreshResult?> _onLoad() async {
    final FastRefreshResult? result = await onLoad();
    if (result is FastRefreshResult) {
      return result;
    }
    if (isNoMore) {
      return FastRefreshResult.noMore;
    }
    return FastRefreshResult.success;
  }

  late FastRefreshController _refreshController;
  bool _ownsRefreshController = false;

  /// 当前绑定的 [FastRefreshController]，供子类编程触发刷新 / 加载。
  @protected
  FastRefreshController get refreshController => _refreshController;

  @override
  void initState() {
    super.initState();
    _updateRefreshController();
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _updateRefreshController();
    }
  }

  @override
  void dispose() {
    if (_ownsRefreshController) {
      _refreshController.dispose();
    }
    super.dispose();
  }

  void _updateRefreshController() {
    if (_ownsRefreshController) {
      _refreshController.dispose();
    }
    final FastRefreshController? controller = widget.controller;
    _ownsRefreshController = controller == null;
    _refreshController = controller ?? FastRefreshController();
  }

  /// 空列表占位。默认读 [FastPaging.emptyWidgetBuilder]。
  @protected
  Widget? buildEmptyWidget() {
    return widget.emptyWidgetBuilder?.call(context);
  }

  /// 进入页自动刷新时的占位。默认读 [FastPaging.refreshOnStartWidgetBuilder]。
  @protected
  Widget? buildRefreshOnStartWidget() {
    return widget.refreshOnStartWidgetBuilder?.call(context);
  }

  /// Header。默认 [FastRefresh.defaultHeaderBuilder]。
  @protected
  FastRefreshHeader buildHeader() => FastRefresh.defaultHeaderBuilder();

  /// Footer。默认 [FastRefresh.defaultFooterBuilder]。
  @protected
  FastRefreshFooter buildFooter() => FastRefresh.defaultFooterBuilder();

  /// 构建滚动视图。默认是挂了 [physics] 的 [CustomScrollView]。
  @protected
  Widget buildScrollView([ScrollPhysics? physics]) {
    return CustomScrollView(
      physics: physics,
      controller: widget.scrollController,
      slivers: buildSlivers(),
    );
  }

  /// 构建 sliver 列表：可选 Locator、空态、条目 sliver。
  @protected
  List<Widget> buildSlivers() {
    final FastRefreshHeader header = buildHeader();
    final FastRefreshFooter footer = buildFooter();
    Widget? emptyWidget;
    if (isEmpty) {
      emptyWidget = buildEmptyWidget();
    }
    return <Widget>[
      if (header.position == FastRefreshIndicatorPosition.locator)
        const FastHeaderLocator.sliver(),
      if (emptyWidget != null)
        SliverFillViewport(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => emptyWidget,
            childCount: 1,
          ),
        ),
      buildSliver(),
      if (footer.position == FastRefreshIndicatorPosition.locator)
        const FastFooterLocator.sliver(),
    ];
  }

  /// 条目 sliver。默认 [SliverList]。
  @protected
  Widget buildSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return buildItem(context, index, getItem(index));
        },
        childCount: count,
      ),
    );
  }

  /// 用 [FastPaging.itemBuilder] 构建条目。
  ///
  /// 子类若把 widget 级 [itemBuilder] 当便捷入口，应显式调用本方法。
  @protected
  Widget buildItemByBuilder(BuildContext context, int index, ItemType item) {
    final FastPagingItemBuilder<ItemType>? itemBuilder = widget.itemBuilder;
    assert(
      itemBuilder != null,
      'Either override buildItem with a custom implementation or provide '
      'itemBuilder before calling buildItemByBuilder.',
    );
    if (itemBuilder == null) {
      throw FlutterError(
        'Either override buildItem with a custom implementation or provide '
        'itemBuilder before calling buildItemByBuilder.',
      );
    }
    return itemBuilder(context, index, item);
  }

  /// 构建第 [index] 条。
  @protected
  Widget buildItem(BuildContext context, int index, ItemType item);

  FastRefreshHeader? _buildRefreshOnStartHeader() {
    final Widget? startWidget = buildRefreshOnStartWidget();
    if (startWidget == null) {
      return null;
    }
    return FastBuilderHeader(
      triggerOffset: 70,
      clamping: true,
      position: FastRefreshIndicatorPosition.above,
      processedDuration: Duration.zero,
      builder: (BuildContext context, FastRefreshIndicatorState state) {
        if (state.mode == FastRefreshMode.inactive ||
            state.mode == FastRefreshMode.done) {
          return const SizedBox();
        }
        return SizedBox(
          width: state.axis == Axis.vertical
              ? double.infinity
              : state.viewportDimension,
          height: state.axis == Axis.horizontal
              ? double.infinity
              : state.viewportDimension,
          child: startWidget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FastRefreshHeader header = buildHeader();
    final FastRefreshFooter footer = buildFooter();
    final FastRefreshHeader? startHeader = _buildRefreshOnStartHeader();
    if (widget.useDefaultPhysics) {
      return FastRefresh(
        header: header,
        footer: footer,
        refreshOnStartHeader: startHeader,
        onRefresh: enableRefresh ? _onRefresh : null,
        onLoad: enableLoad ? _onLoad : null,
        controller: _refreshController,
        spring: widget.spring,
        frictionFactor: widget.frictionFactor,
        notRefreshHeader: widget.notRefreshHeader,
        notLoadFooter: widget.notLoadFooter,
        simultaneously: widget.simultaneously,
        canRefreshAfterNoMore: widget.canRefreshAfterNoMore,
        canLoadAfterNoMore: widget.canLoadAfterNoMore,
        resetAfterRefresh: widget.resetAfterRefresh,
        refreshOnStart: widget.refreshOnStart,
        callRefreshOverOffset: widget.callRefreshOverOffset,
        callLoadOverOffset: widget.callLoadOverOffset,
        fit: widget.fit,
        clipBehavior: widget.clipBehavior,
        scrollBehaviorBuilder: widget.scrollBehaviorBuilder,
        scrollController: widget.scrollController,
        triggerAxis: widget.triggerAxis,
        isNested: widget.isNested,
        child: buildScrollView(),
      );
    }
    return FastRefresh.builder(
      header: header,
      footer: footer,
      refreshOnStartHeader: startHeader,
      onRefresh: enableRefresh ? _onRefresh : null,
      onLoad: enableLoad ? _onLoad : null,
      controller: _refreshController,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
      notRefreshHeader: widget.notRefreshHeader,
      notLoadFooter: widget.notLoadFooter,
      simultaneously: widget.simultaneously,
      canRefreshAfterNoMore: widget.canRefreshAfterNoMore,
      canLoadAfterNoMore: widget.canLoadAfterNoMore,
      resetAfterRefresh: widget.resetAfterRefresh,
      refreshOnStart: widget.refreshOnStart,
      callRefreshOverOffset: widget.callRefreshOverOffset,
      callLoadOverOffset: widget.callLoadOverOffset,
      fit: widget.fit,
      clipBehavior: widget.clipBehavior,
      scrollBehaviorBuilder: widget.scrollBehaviorBuilder,
      scrollController: widget.scrollController,
      triggerAxis: widget.triggerAxis,
      isNested: widget.isNested,
      childBuilder: (BuildContext context, ScrollPhysics physics) {
        return buildScrollView(physics);
      },
    );
  }
}
