part of 'fast_refresh.dart';

/// [FastRefresh] 向下共享的运行时数据。
class FastRefreshData {
  /// Header 状态与通知。
  final FastRefreshHeaderNotifier headerNotifier;

  /// Footer 状态与通知。
  final FastRefreshFooterNotifier footerNotifier;

  /// 用户是否正在拖拽。`true` 表示手指未离开。
  final ValueNotifier<bool> userOffsetNotifier;

  /// 创建共享数据。
  const FastRefreshData({
    required this.headerNotifier,
    required this.footerNotifier,
    required this.userOffsetNotifier,
  });
}

/// 向子树提供 [FastRefreshData]，供 Locator 等组件读取。
class _InheritedFastRefresh extends InheritedWidget {
  /// 当前作用域的运行时数据。
  final FastRefreshData data;

  const _InheritedFastRefresh({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedFastRefresh oldWidget) =>
      data != oldWidget.data;
}

/// 下拉刷新、上拉 / 触底加载包装器。
///
/// 有两种用法，对齐 EasyRefresh：
///
/// - **[FastRefresh]（Widget 构造）**：把 physics 注入 [child] 所在作用域，
///   适合单个 [ListView]。见 [FastRefresh.new]。
/// - **[FastRefresh.builder]**：把 physics 交给 [childBuilder]，适合嵌套滚动。
///   对比与取舍见 [FastRefreshChildBuilder]。
///
/// 不要在默认构造的 [child] 里再嵌套另一套独立滚动，除非给里层单独设
/// physics，或改用 [FastRefresh.builder]。
class FastRefresh extends StatefulWidget {
  /// 可滚动内容，通常是 [ListView] 或 [CustomScrollView]。
  /// [FastRefresh.builder] 构造下为 `null`。
  final Widget? child;

  /// 可选的编程控制器。
  final FastRefreshController? controller;

  /// Header。默认 [FastClassicHeader]。
  final FastRefreshHeader? header;

  /// Footer。默认 [FastClassicFooter]。
  final FastRefreshFooter? footer;

  /// [onRefresh] 为 `null` 时的越界行为，不构建可见组件。
  final FastNotRefreshHeader? notRefreshHeader;

  /// [onLoad] 为 `null` 时的越界行为，不构建可见组件。
  final FastNotLoadFooter? notLoadFooter;

  /// 自行挂 physics 的构建器。[FastRefresh] 普通构造下为 `null`。
  final FastRefreshChildBuilder? childBuilder;

  /// 刷新回调。`null` 表示关闭刷新。
  ///
  /// 触发时 Header 处于 [FastRefreshMode.processing]。
  /// 可返回 [FastRefreshResult]；否则视为成功，抛错视为失败。
  /// [FastRefreshController.controlFinishRefresh] 为 `true` 时返回值无效。
  final FutureOr Function()? onRefresh;

  /// 加载回调。`null` 表示关闭加载。语义同 [onRefresh]。
  final FutureOr Function()? onLoad;

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

  /// [refreshOnStart] 时使用的 Header；`null` 则用 [header]。
  final FastRefreshHeader? refreshOnStartHeader;

  /// [FastRefreshController.callRefresh] / [refreshOnStart] 多拉出的距离。
  final double callRefreshOverOffset;

  /// [FastRefreshController.callLoad] 多拉出的距离。
  final double callLoadOverOffset;

  /// 见 [Stack.fit]。
  final StackFit fit;

  /// 见 [Stack.clipBehavior]。
  final Clip clipBehavior;

  /// 滚动行为工厂。默认 [FastRefreshScrollBehavior]。
  ///
  /// ```dart
  /// FastRefresh(
  ///   scrollBehaviorBuilder: (ScrollPhysics? physics) {
  ///     return YourCustomScrollBehavior(physics);
  ///   },
  /// )
  /// ```
  final FastRefreshScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// 无法从 [ScrollMetrics] 拿到 [ScrollPosition] 时（如 [NestedScrollView]）
  /// 用于编程滚动。请同时绑到 [Scrollable.controller]。
  final ScrollController? scrollController;

  /// 只在该轴上展示指示器并执行任务；`null` 表示不限制。
  final Axis? triggerAxis;

  /// 为 `true` 时按 NestedScrollView 处理内外层。默认 `false`，避免普通列表额外开销。
  final bool isNested;

  /// 全局默认 Header 工厂，可替换。
  static FastRefreshHeader Function() defaultHeaderBuilder = _defaultHeaderBuilder;

  /// 内置默认 Header：[FastClassicHeader]。
  static FastRefreshHeader _defaultHeaderBuilder() => const FastClassicHeader();

  /// 当前全局默认 Header 实例。
  static FastRefreshHeader get _defaultHeader => defaultHeaderBuilder.call();

  /// 全局默认 Footer 工厂，可替换。
  static FastRefreshFooter Function() defaultFooterBuilder = _defaultFooterBuilder;

  /// 内置默认 Footer：[FastClassicFooter]。
  static FastRefreshFooter _defaultFooterBuilder() => const FastClassicFooter();

  /// 当前全局默认 Footer 实例。
  static FastRefreshFooter get _defaultFooter => defaultFooterBuilder.call();

  /// 全局默认 [ScrollBehavior] 工厂，可替换。
  static ScrollBehavior Function(ScrollPhysics? physics)
      defaultScrollBehaviorBuilder = _defaultScrollBehaviorBuilder;

  /// 内置默认滚动行为：[FastRefreshScrollBehavior]。
  static ScrollBehavior _defaultScrollBehaviorBuilder(ScrollPhysics? physics) =>
      FastRefreshScrollBehavior(physics);

  /// Widget 构造：用 [child] 创建刷新包装。
  ///
  /// physics 通过 [ScrollConfiguration] 注入子树，[child] 里的 [ScrollView]
  /// **不必**再写 `physics`。嵌套多个滚动视图时请改用 [FastRefresh.builder]。
  ///
  /// 与 builder 的对比见 [FastRefreshChildBuilder]。
  const FastRefresh({
    super.key,
    required this.child,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
  })  : childBuilder = null,
        assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  /// Builder 构造：自行把 [childBuilder] 收到的 physics 挂到滚动视图上。
  ///
  /// 此时 [ScrollConfiguration] **不会**注入 physics（传入 `null`），
  /// 漏写 `physics: physics` 则列表仍用平台默认物理，下拉不会进入刷新状态机。
  ///
  /// 适合 [NestedScrollView]、[PageView] 套列表、外层还有独立滚动的页面。
  /// 与 Widget 构造的对比见 [FastRefreshChildBuilder]。
  const FastRefresh.builder({
    super.key,
    required this.childBuilder,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
  })  : child = null,
        assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  @override
  State<StatefulWidget> createState() => _FastRefreshState();

  /// 读取当前作用域的 [FastRefreshData]。必须在 [FastRefresh] 子树内调用。
  static FastRefreshData of(BuildContext context) {
    final inheritedFastRefresh =
        context.dependOnInheritedWidgetOfExactType<_InheritedFastRefresh>();
    assert(inheritedFastRefresh != null,
        'Please use it in the scope of FastRefresh!');
    return inheritedFastRefresh!.data;
  }

  /// Reads [FastRefreshData] when inside a [FastRefresh]; otherwise `null`.
  /// 在 [FastRefresh] 子树内读取 [FastRefreshData]；否则返回 `null`。
  static FastRefreshData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedFastRefresh>()
        ?.data;
  }
}

/// [FastRefresh] 的状态：组装 physics、notifier，并按 position 叠指示器。
class _FastRefreshState extends State<FastRefresh>
    with TickerProviderStateMixin {
  /// 注入给子滚动视图的物理。
  late _FRScrollPhysics _physics;

  /// 向下共享的运行时数据。
  late FastRefreshData _data;

  /// 用户是否正在拖拽。
  ValueNotifier<bool> get _userOffsetNotifier => _data.userOffsetNotifier;

  /// Header notifier。
  FastRefreshHeaderNotifier get _headerNotifier => _data.headerNotifier;

  /// Footer notifier。
  FastRefreshFooterNotifier get _footerNotifier => _data.footerNotifier;

  /// 当前是否处于「进入页自动刷新」。
  bool _isRefreshOnStart = false;

  /// 是否等待刷新回调返回结果。接管完成事件时为 `false`。
  bool get _waitRefreshResult =>
      !(widget.controller?.controlFinishRefresh ?? false);

  /// 是否等待加载回调返回结果。接管完成事件时为 `false`。
  bool get _waitLoadResult => !(widget.controller?.controlFinishLoad ?? false);

  /// 实际使用的 Header。关闭刷新时换成 [FastNotRefreshHeader]。
  FastRefreshHeader get _header {
    if (widget.onRefresh == null) {
      if (widget.notRefreshHeader != null) {
        return widget.notRefreshHeader!;
      } else {
        final h = widget.header ?? FastRefresh._defaultHeader;
        return FastNotRefreshHeader(
          clamping: h.clamping,
          position: h.position,
          spring: h.spring,
          frictionFactor: h.frictionFactor,
          hitOver: h.hitOver,
          maxOverOffset: h.maxOverOffset,
        );
      }
    } else {
      FastRefreshHeader h = widget.header ?? FastRefresh._defaultHeader;
      if (_isRefreshOnStart) {
        h = FastOverrideHeader(
          header: widget.refreshOnStartHeader ?? h,
          triggerWhenReach: true,
        );
      }
      return h;
    }
  }

  /// 实际使用的 Footer。关闭加载时换成 [FastNotLoadFooter]。
  FastRefreshFooter get _footer {
    if (widget.onLoad == null) {
      if (widget.notLoadFooter != null) {
        return widget.notLoadFooter!;
      } else {
        final f = widget.footer ?? FastRefresh._defaultFooter;
        return FastNotLoadFooter(
          clamping: f.clamping,
          position: f.position,
          spring: f.spring,
          frictionFactor: f.frictionFactor,
          hitOver: f.hitOver,
          maxOverOffset: f.maxOverOffset,
        );
      }
    } else {
      return widget.footer ?? FastRefresh._defaultFooter;
    }
  }

  @override
  void initState() {
    super.initState();
    // 进入页自动刷新：首帧后再 jumpTo 触发位。
    if (widget.refreshOnStart && widget.onRefresh != null) {
      _isRefreshOnStart = true;
      Future(() {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _callRefresh(
            overOffset: widget.callRefreshOverOffset,
            duration: null,
          );
        });
      });
    }
    _initData();
    widget.controller?._bind(this);
  }

  @override
  void didUpdateWidget(covariant FastRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步 Header / Footer 配置与任务回调。
    _headerNotifier._update(
      indicator: _header,
      canProcessAfterNoMore: widget.canRefreshAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: _onRefresh,
      waitTaskRefresh: _waitRefreshResult,
      isNested: widget.isNested,
    );
    _footerNotifier._update(
      indicator: _footer,
      canProcessAfterNoMore: widget.canLoadAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: widget.onLoad,
      waitTaskRefresh: _waitLoadResult,
      isNested: widget.isNested,
    );
    // 控制器被替换时先解绑旧的，再绑定新的。
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind(this);
      widget.controller?._bind(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(this);
    _headerNotifier.dispose();
    _footerNotifier.dispose();
    _userOffsetNotifier.dispose();
    super.dispose();
  }

  /// 创建 notifier、physics 与共享数据。
  void _initData() {
    final userOffsetNotifier = ValueNotifier<bool>(false);
    _data = FastRefreshData(
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: FastRefreshHeaderNotifier(
        header: _header,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onRefresh: _onRefresh,
        canProcessAfterNoMore: widget.canRefreshAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitRefreshResult: _waitRefreshResult,
        onCanRefresh: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_footerNotifier._processing;
          }
        },
      ),
      footerNotifier: FastRefreshFooterNotifier(
        footer: _footer,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onLoad: widget.onLoad,
        canProcessAfterNoMore: widget.canLoadAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitLoadResult: _waitLoadResult,
        onCanLoad: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_headerNotifier._processing && !_isRefreshOnStart;
          }
        },
      ),
    );
    _physics = _FRScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
    );
  }

  /// 自动刷新回到 [FastRefreshMode.inactive] 后，换回普通 Header 并停止监听。
  void _refreshOnStartListener() {
    if (_headerNotifier._mode == FastRefreshMode.inactive) {
      _isRefreshOnStart = false;
      _headerNotifier.removeListener(_refreshOnStartListener);
      _headerNotifier._update(
        indicator: _header,
        task: _onRefresh,
      );
    }
  }

  /// 包装后的刷新任务：处理 [FastRefresh.refreshOnStart] 与 [FastRefresh.resetAfterRefresh]。
  ///
  /// 未接管完成时，仅在结果为成功时清 Footer `noMore`。
  /// 接管完成时由 [_finishRefresh] 在 [FastRefreshController.finishRefresh] 里处理。
  FutureOr Function()? get _onRefresh {
    if (widget.onRefresh == null) {
      return null;
    }
    return () async {
      if (_isRefreshOnStart) {
        _headerNotifier.addListener(_refreshOnStartListener);
      }
      final res = await Future.sync(widget.onRefresh!);
      if (_waitRefreshResult &&
          widget.resetAfterRefresh &&
          _isRefreshSuccessResult(res)) {
        _footerNotifier._reset();
      }
      return res;
    };
  }

  /// `null` / 非 [FastRefreshResult] / [FastRefreshResult.success] 视为成功。
  static bool _isRefreshSuccessResult(Object? result) {
    if (result is FastRefreshResult) {
      return result == FastRefreshResult.success;
    }
    return true;
  }

  /// 结束刷新。成功且 [FastRefresh.resetAfterRefresh] 时清 Footer `noMore`。
  void _finishRefresh(FastRefreshResult result) {
    _headerNotifier._finishTask(result);
    if (widget.resetAfterRefresh && result == FastRefreshResult.success) {
      _footerNotifier._reset();
    }
  }

  /// 编程触发刷新。
  Future _callRefresh({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    return _headerNotifier.callTask(
      overOffset: overOffset ?? widget.callRefreshOverOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController ?? widget.scrollController,
      force: force,
    );
  }

  /// 编程触发加载。
  Future _callLoad({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    return _footerNotifier.callTask(
      overOffset: overOffset ?? widget.callLoadOverOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController ?? widget.scrollController,
      force: force,
    );
  }

  /// 按轴方向把 Header 钉在视口边缘。
  Widget _buildHeaderView() {
    return ValueListenableBuilder(
      valueListenable: _headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // 物理尚未写入轴信息时先占位。
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // 把安全区写入 notifier，计入实际触发距离。
        final safePadding = MediaQuery.of(context).padding;
        _headerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                ? safePadding.top
                : safePadding.bottom
            : axisDirection == AxisDirection.right
                ? safePadding.left
                : safePadding.right;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          child: _headerNotifier._build(context),
        );
      },
    );
  }

  /// 按轴方向把 Footer 钉在视口边缘。
  Widget _buildFooterView() {
    return ValueListenableBuilder(
      valueListenable: _footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        final safePadding = MediaQuery.of(context).padding;
        _footerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                ? safePadding.bottom
                : safePadding.top
            : axisDirection == AxisDirection.right
                ? safePadding.right
                : safePadding.left;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          child: _footerNotifier._build(context),
        );
      },
    );
  }

  /// 实际使用的 [ScrollBehavior] 工厂。
  FastRefreshScrollBehaviorBuilder get _scrollBehaviorBuilder =>
      widget.scrollBehaviorBuilder ?? FastRefresh.defaultScrollBehaviorBuilder;

  /// 构建内容：按构造方式注入或不注入 physics，并向子树提供 [FastRefreshData]。
  ///
  /// - Widget 构造：[_scrollBehaviorBuilder] 带上 [_physics]，子树自动越界。
  /// - builder 构造：behavior 的 physics 为 `null`，由 [childBuilder] 挂到目标滚动视图。
  Widget _buildContent() {
    Widget child;
    if (widget.childBuilder != null) {
      // builder：不把 physics 塞进作用域，避免嵌套 ScrollView 误用同一份物理。
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(null),
        child: widget.childBuilder!(context, _physics),
      );
    } else {
      // Widget 构造：作用域内所有未单独指定 physics 的 ScrollView 共用这份物理。
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(_physics),
        child: widget.child!,
      );
    }
    return _InheritedFastRefresh(
      data: _data,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentWidget = _buildContent();
    final List<Widget> children = [];
    final hPosition = _headerNotifier.iPosition;
    final fPosition = _footerNotifier.iPosition;
    // behind 先画、above 后画，保证叠放顺序。
    if (hPosition == FastRefreshIndicatorPosition.behind) {
      children.add(_buildHeaderView());
    }
    if (fPosition == FastRefreshIndicatorPosition.behind) {
      children.add(_buildFooterView());
    }
    children.add(contentWidget);
    if (hPosition == FastRefreshIndicatorPosition.above) {
      children.add(_buildHeaderView());
    }
    if (fPosition == FastRefreshIndicatorPosition.above) {
      children.add(_buildFooterView());
    }
    // locator / custom 时 Stack 只有内容，直接返回，避免多余裁剪。
    if (children.length == 1) {
      children.clear();
      return contentWidget;
    }
    return ClipPath(
      clipBehavior: widget.clipBehavior,
      child: Stack(
        clipBehavior: Clip.none,
        fit: widget.fit,
        children: children,
      ),
    );
  }
}
