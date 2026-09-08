part of 'fast_refresh.dart';

/// [FastRefresh] 的编程控制器。
///
/// 用于主动触发刷新 / 加载、结束任务、重置 `noMore`，以及打开 / 关闭二楼。
class FastRefreshController {
  /// 为 `true` 时，刷新完成必须调用 [finishRefresh]，回调返回值无效。
  final bool controlFinishRefresh;

  /// 为 `true` 时，加载完成必须调用 [finishLoad]，回调返回值无效。
  final bool controlFinishLoad;

  /// 绑定的 [FastRefresh] 状态。未挂载或已 [dispose] 时为 `null`。
  _FastRefreshState? _state;

  /// 创建控制器。
  FastRefreshController({
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
  });

  /// 与 [FastRefresh] 绑定。由 [_FastRefreshState] 在 init / 更新时调用。
  void _bind(_FastRefreshState state) {
    _state = state;
  }

  /// 编程触发刷新：先越过触发位，再由弹簧吸回并进入 `processing`。
  ///
  /// [overOffset] 超出触发距离的额外偏移，必须大于 0。
  /// [duration] 动画时长，见 [ScrollPosition.animateTo]；`null` 表示瞬间跳转。
  /// [curve] 动画曲线。
  /// [scrollController] 当前 [ScrollMetrics] 不是 [ScrollPosition] 时可用。
  /// [force] 为 `true` 时，即使任务进行中也强制执行，调用方需自行收尾。
  Future callRefresh({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) async {
    await _state?._callRefresh(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
      force: force,
    );
  }

  /// 编程触发加载。参数含义同 [callRefresh]。
  Future callLoad({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) async {
    await _state?._callLoad(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
      force: force,
    );
  }

  /// 打开 Header 二楼。未配置 [FastRefreshIndicator.secondaryTriggerOffset] 时为空操作。
  Future openHeaderSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._header.secondaryTriggerOffset != null) {
      final headerNotifier = _state!._headerNotifier;
      if (headerNotifier.modeLocked ||
          headerNotifier.noMoreLocked ||
          headerNotifier.secondaryLocked ||
          !headerNotifier._canProcess) {
        return;
      }
      await headerNotifier.animateToOffset(
        offset: headerNotifier.secondaryDimension,
        mode: FastRefreshMode.secondaryOpen,
        duration: duration,
        curve: curve,
        scrollController: scrollController ?? _state?.widget.scrollController,
      );
    }
  }

  /// 关闭 Header 二楼。当前不是 [FastRefreshMode.secondaryOpen] 时为空操作。
  Future closeHeaderSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._header.secondaryTriggerOffset != null) {
      final headerNotifier = _state!._headerNotifier;
      if (headerNotifier.mode != FastRefreshMode.secondaryOpen) {
        return;
      }
      await headerNotifier.animateToOffset(
        offset: 0,
        mode: FastRefreshMode.inactive,
        jumpToEdge: false,
        duration: duration,
        curve: curve,
        scrollController: scrollController ?? _state?.widget.scrollController,
      );
    }
  }

  /// 打开 Footer 二楼。
  Future openFooterSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._footer.secondaryTriggerOffset != null) {
      final footerNotifier = _state!._footerNotifier;
      if (footerNotifier.modeLocked ||
          footerNotifier.noMoreLocked ||
          footerNotifier.secondaryLocked ||
          !footerNotifier._canProcess) {
        return;
      }
      await footerNotifier.animateToOffset(
        offset: footerNotifier.secondaryDimension,
        mode: FastRefreshMode.secondaryOpen,
        jumpToEdge: false,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// 关闭 Footer 二楼。
  Future closeFooterSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._footer.secondaryTriggerOffset != null) {
      final footerNotifier = _state!._footerNotifier;
      if (footerNotifier.mode != FastRefreshMode.secondaryOpen) {
        return;
      }
      await footerNotifier.animateToOffset(
        offset: 0,
        mode: FastRefreshMode.inactive,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// 重置 Header 指示器状态（例如清掉 Header 的 `noMore`）。
  void resetHeader() {
    _state?._headerNotifier._reset();
  }

  /// 重置 Footer 指示器状态（例如清掉 Footer 的 `noMore`，以便再次加载）。
  void resetFooter() {
    _state?._footerNotifier._reset();
  }

  /// 结束刷新并写入结果。
  ///
  /// 需先将 [controlFinishRefresh] 设为 `true`。若只想改结果，可传 [force] `true`。
  void finishRefresh(
      [FastRefreshResult result = FastRefreshResult.success, bool force = false]) {
    assert(controlFinishRefresh || force,
        'Please set controlFinishRefresh to true, then use. If you want to modify the result, you can set force to true.');
    _state?._headerNotifier._finishTask(result);
  }

  /// 结束加载并写入结果。
  ///
  /// 需先将 [controlFinishLoad] 设为 `true`。若只想改结果，可传 [force] `true`。
  void finishLoad(
      [FastRefreshResult result = FastRefreshResult.success, bool force = false]) {
    assert(controlFinishLoad || force,
        'Please set controlFinishLoad to true, then use. If you want to modify the result, you can set force to true.');
    _state?._footerNotifier._finishTask(result);
  }

  /// 与 [FastRefresh] 解绑。通常在页面 dispose 时调用。
  void dispose() {
    _state = null;
  }

  /// 当前 Header 快照；未挂载或轴信息未就绪时为 `null`。
  FastRefreshIndicatorState? get headerState => _state?._headerNotifier.indicatorState;

  /// 当前 Footer 快照；未挂载或轴信息未就绪时为 `null`。
  FastRefreshIndicatorState? get footerState => _state?._footerNotifier.indicatorState;
}
