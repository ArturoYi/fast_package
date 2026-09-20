// ignore_for_file: invalid_use_of_visible_for_testing_member

part of 'fast_refresh.dart';

/// 是否允许执行任务（刷新 / 加载互斥等）。
typedef CanProcessCallBack = bool Function();

/// 模式变化监听。参数为新模式与当前偏移。
typedef ModeChangeListener = void Function(FastRefreshMode mode, double offset);

/// 当前帧是否还在 build / layout / paint。此时 [setState] 会触发
/// `Build scheduled during frame`。
bool _refreshInPersistentFrame() {
  return SchedulerBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks;
}

/// 把 listener 转发延到帧后，避免指示器在 layout 里 [setState]。
class _DeferredListenerGate {
  bool _scheduled = false;

  void run(List<VoidCallback> listeners) {
    if (_refreshInPersistentFrame()) {
      if (_scheduled) {
        return;
      }
      _scheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scheduled = false;
        _forward(listeners);
      });
      return;
    }
    _forward(listeners);
  }

  static void _forward(List<VoidCallback> listeners) {
    for (final VoidCallback listener in List<VoidCallback>.of(listeners)) {
      listener();
    }
  }
}

/// Header / Footer 的状态机：偏移、模式切换、任务执行。
abstract class FastRefreshNotifier extends ChangeNotifier {
  /// 当前指示器配置。
  FastRefreshIndicator _indicator;

  /// clamping 动画的 vsync。
  final TickerProviderStateMixin vsync;

  /// 用户是否正在拖拽。`true` 表示手指未离开。
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// 触发后执行的任务。可返回 [FastRefreshResult]。
  FutureOr Function()? _task;

  /// 是否等待任务 Future 结束再进入 processed。
  bool _waitTaskResult;

  /// 是否仍挂在 [FastRefresh] 上。
  bool _mounted = false;

  /// 只在该轴上展示并执行任务；`null` 表示不限制。
  Axis? _triggerAxis;

  /// 创建 notifier，并绑定 [listenable]、用户拖拽监听与 clamping 动画。
  FastRefreshNotifier({
    required FastRefreshIndicator indicator,
    required this.vsync,
    required this.userOffsetNotifier,
    required CanProcessCallBack onCanProcess,
    required bool canProcessAfterNoMore,
    required bool isNested,
    Axis? triggerAxis,
    bool waitTaskResult = true,
    FutureOr Function()? task,
  })  : _indicator = indicator,
        _onCanProcess = onCanProcess,
        _canProcessAfterNoMore = canProcessAfterNoMore,
        _isNested = isNested,
        _triggerAxis = triggerAxis,
        _waitTaskResult = waitTaskResult,
        _task = task {
    _initClampingAnimation();
    userOffsetNotifier.addListener(_onUserOffset);
    indicator.listenable?._bind(this);
    _mounted = true;
  }

  /// 见 [FastRefreshIndicator.triggerOffset]。
  double get triggerOffset => _indicator.triggerOffset;

  /// 见 [FastRefreshIndicator.clamping]。
  bool get clamping => _indicator.clamping;

  /// 见 [FastRefreshIndicator.safeArea]。
  bool get safeArea => _indicator.safeArea;

  /// 见 [FastRefreshIndicator.processedDuration]。
  Duration get processedDuration => _indicator.processedDuration;

  /// 见 [FastRefreshIndicator.infiniteOffset]。
  double? get infiniteOffset => _indicator.infiniteOffset;

  /// 见 [FastRefreshIndicator.hitOver]。
  bool get hitOver => _indicator.hitOver;

  /// 见 [FastRefreshIndicator.infiniteHitOver]。
  bool get infiniteHitOver => _indicator.infiniteHitOver;

  /// 见 [FastRefreshIndicator.position]。
  FastRefreshIndicatorPosition get iPosition => _indicator.position;

  /// 见 [FastRefreshIndicator.secondaryTriggerOffset]。
  double? get secondaryTriggerOffset => _indicator.secondaryTriggerOffset;

  /// 见 [FastRefreshIndicator.secondaryVelocity]。
  double get secondaryVelocity => _indicator.secondaryVelocity;

  /// 见 [FastRefreshIndicator.maxOverOffset]。
  double get maxOverOffset => _indicator.maxOverOffset;

  /// 实际越界上限（含安全区）。无限时保持 [double.infinity]。
  double get actualMaxOverOffset => maxOverOffset == double.infinity
      ? maxOverOffset
      : (maxOverOffset + safeOffset);

  /// 当前轴对应的回弹弹簧。
  physics.SpringDescription? get _spring {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalSpring ?? _indicator.spring;
    } else {
      return _indicator.spring;
    }
  }

  /// 当前物理使用的弹簧。
  physics.SpringDescription get spring => _physics.spring;

  /// 当前轴对应的 ready 弹簧构建器。
  FastRefreshSpringBuilder? get readySpringBuilder {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalReadySpringBuilder ??
          _indicator.readySpringBuilder;
    } else {
      return _indicator.readySpringBuilder;
    }
  }

  /// 当前轴对应的越界摩擦。
  FastRefreshFrictionFactor? get _frictionFactor {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalFrictionFactor ?? _indicator.frictionFactor;
    } else {
      return _indicator.frictionFactor;
    }
  }

  /// 当前物理使用的越界摩擦。
  FastRefreshFrictionFactor get frictionFactor => _physics.frictionFactor;

  /// 二楼高度；未指定时等于视口尺寸。
  double get secondaryDimension =>
      _indicator.secondaryDimension ?? viewportDimension;

  /// 见 [FastRefreshIndicator.secondaryCloseTriggerOffset]。
  double get secondaryCloseTriggerOffset =>
      _indicator.secondaryCloseTriggerOffset;

  /// 见 [FastRefreshIndicator.hapticFeedback]。
  bool get hapticFeedback => _indicator.hapticFeedback;

  /// 是否配置了二楼。
  bool get hasSecondary => secondaryTriggerOffset != null;

  /// 滚动轴与方向。
  Axis? _axis;

  Axis? get axis => _axis;

  AxisDirection? _axisDirection;

  AxisDirection? get axisDirection => _axisDirection;

  /// 安全区偏移，避免刘海 / Home 条挡住指示器。
  /// 实际触发距离 = [triggerOffset] + [safeOffset]。
  double? _safeOffset;

  double get safeOffset => safeArea ? _safeOffset ?? 0 : 0;

  /// 当前越界偏移。
  double _offset = 0;

  double get offset => _offset;

  /// 当前滚动度量。
  ScrollMetrics get position => _position!;

  /// 当前度量若是 [ScrollPosition] 则返回，否则为 `null`。
  ScrollPosition? _effectiveScrollPosition() {
    if (_position is ScrollPosition) {
      return _position as ScrollPosition;
    }
    return null;
  }

  /// [scrollController] 持有 [position] 时才使用它，避免滚错列表。
  ScrollController? _matchingScrollController(
      ScrollController? scrollController, ScrollPosition position) {
    if (!(scrollController?.hasClients ?? false)) {
      return null;
    }
    return scrollController!.positions.contains(position)
        ? scrollController
        : null;
  }

  /// 是否按 NestedScrollView 处理内外层。
  bool _isNested;

  bool get isNested => _isNested;

  /// 写入当前滚动度量；NestedScrollView 时额外缓存视口尺寸。
  set position(ScrollMetrics value) {
    if (_isNested) {
      if (value.isNestedOuter) {
        _viewportDimension = value.viewportDimension;
      } else if (value.isNestedInner) {
        if (WidgetsBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
          _viewportDimension = value.axis == Axis.vertical
              ? vsync.context.size?.height
              : vsync.context.size?.width;
        }
      }
    } else {
      _viewportDimension = null;
    }
    _position = value;
    _lastMaxScrollExtent = value.maxScrollExtent;
  }

  ScrollMetrics? _position;

  /// 上次的 maxScrollExtent，用于判断内容高度是否变化。
  double? _lastMaxScrollExtent;

  /// 当前滚动速度。
  double _velocity = 0;

  double get velocity => _velocity;

  /// 当前生命周期。
  FastRefreshMode __mode = FastRefreshMode.inactive;

  FastRefreshMode get _mode => __mode;

  set _mode(FastRefreshMode mode) {
    final oldMode = __mode;
    __mode = mode;
    if (mode != oldMode) {
      for (final listener in _modeChangeListeners) {
        listener(mode, _offset);
      }
    }
  }

  /// 当前生命周期，对外只读。
  FastRefreshMode get mode => _mode;

  /// clamping 为 true 时驱动指示器回弹的动画。
  AnimationController? _clampingAnimationController;

  /// 绑定的滚动物理。
  late _FRScrollPhysics _physics;

  /// 松手瞬间的偏移。用于判断是否满足触发条件。
  double _releaseOffset = 0;

  /// 模式变化监听集合。
  final Set<ModeChangeListener> _modeChangeListeners = {};

  /// 实际触发距离：[triggerOffset] + [safeOffset]。
  double get actualTriggerOffset => triggerOffset + safeOffset;

  /// 实际二楼触发距离：[secondaryTriggerOffset] + [safeOffset]。
  double get actualSecondaryTriggerOffset =>
      secondaryTriggerOffset! + safeOffset;

  /// 当前轴是否与 [triggerAxis] 一致。
  bool get _isSupportAxis {
    if (_triggerAxis == null || _axis == null) {
      return true;
    }
    return _axis == _triggerAxis;
  }

  /// 需要列表保持越界的距离（ready / processing / 无限加载 / 二楼）。
  double get overExtent {
    // 轴不匹配则不保持越界。
    if (!_isSupportAxis) {
      return 0;
    }
    // 无任务或不可执行时不保持越界。
    if (_task == null ||
        (!_canProcess && !noMoreLocked) ||
        (noMoreLocked && infiniteOffset == null)) {
      return 0;
    }
    // ready / 任务中 / 无限加载：保持在触发位。
    if (infiniteOffset != null ||
        _mode == FastRefreshMode.ready ||
        modeLocked ||
        noMoreLocked) {
      return actualTriggerOffset;
    }
    // 二楼：保持当前或二楼高度。
    if (_mode == FastRefreshMode.secondaryArmed && userOffsetNotifier.value) {
      return offset;
    }
    if (_mode == FastRefreshMode.secondaryReady ||
        _mode == FastRefreshMode.secondaryOpen) {
      return secondaryDimension;
    }
    return 0;
  }

  /// processing / processed 期间锁定，避免被拖拽打断。
  bool get modeLocked =>
      _mode == FastRefreshMode.processing || _mode == FastRefreshMode.processed;

  /// 是否处于越界（clamping 时看指示器 offset）。
  bool get outOfRange {
    if (clamping) {
      return !modeLocked && _offset > 0;
    }
    return _offset > 0;
  }

  /// 供指示器组件监听的 ValueListenable。
  ValueListenable<FastRefreshNotifier> listenable() =>
      _IndicatorListenable(this);

  /// 任务是否正在执行。
  bool _processing = false;

  /// 是否允许执行任务。
  CanProcessCallBack? _onCanProcess;

  bool get _canProcess => _onCanProcess?.call() ?? false;

  /// 最近一次任务结果。
  FastRefreshResult _result = FastRefreshResult.none;

  /// `noMore` 之后是否仍允许再次触发。
  bool _canProcessAfterNoMore;

  /// `noMore` 且未允许再次触发时锁定。
  bool get noMoreLocked =>
      !_canProcessAfterNoMore &&
      _result == FastRefreshResult.noMore &&
      _mode == FastRefreshMode.inactive;

  /// 视口尺寸。
  double get viewportDimension =>
      _viewportDimension ?? position.viewportDimension;

  double? _viewportDimension;

  /// 由滚动像素计算越界偏移。
  double _calculateOffset(ScrollMetrics position, double value);

  /// 由绝对像素计算越界偏移（clamping 动画用）。
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels);

  /// 无限滚动时需要排除的边界（对侧边缘）。
  bool _infiniteExclude(ScrollMetrics position, double value);

  /// 滚动到指定越界偏移。
  ///
  /// [offset] 目标越界距离。
  /// [mode] [duration] 为 `null` 且 clamping 时直接写入的模式。
  /// [jumpToEdge] 动画前是否先跳到边缘。
  /// [duration] / [curve] 见 [ScrollPosition.animateTo]；`null` 表示瞬间跳转。
  /// [scrollController] 当前度量不是 [ScrollPosition] 时可用。
  Future animateToOffset({
    required double offset,
    required FastRefreshMode mode,
    bool jumpToEdge = true,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  });

  /// 二楼已打开或正在关闭。
  bool get secondaryLocked =>
      _mode == FastRefreshMode.secondaryOpen ||
      _mode == FastRefreshMode.secondaryClosing;

  /// 解绑监听并释放 clamping 动画。
  @override
  void dispose() {
    _onCanProcess = null;
    _clampingAnimationController?.dispose();
    userOffsetNotifier.removeListener(_onUserOffset);
    _task = null;
    _modeChangeListeners.clear();
    _indicator.listenable?._unbind();
    _mounted = false;
    super.dispose();
  }

  /// 添加模式变化监听。
  void addModeChangeListener(ModeChangeListener listener) {
    _modeChangeListeners.add(listener);
  }

  /// 移除模式变化监听。
  void removeModeChangeListener(ModeChangeListener listener) {
    _modeChangeListeners.remove(listener);
  }

  /// 初始化 clamping 动画控制器。
  void _initClampingAnimation() {
    if (clamping) {
      _clampingAnimationController = AnimationController.unbounded(
        vsync: vsync,
      );
      _clampingAnimationController!.addListener(_clampingTick);
    }
  }

  /// 监听用户按下 / 松开。
  void _onUserOffset() {
    if (userOffsetNotifier.value) {
      // 用户重新拖拽时打断 clamping 回弹。
      if (clamping && _clampingAnimationController!.isAnimating) {
        _clampingAnimationController!.stop(canceled: true);
      }
    } else {
      // 松手瞬间记下偏移，供 armed / ready / 二楼判断。
      _releaseOffset = _offset;
    }
  }

  /// 绑定滚动物理。
  void _bindPhysics(_FRScrollPhysics physics) {
    _physics = physics;
  }

  /// 为 clamping 创建惯性模拟。
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity);

  /// 距对应边缘的距离。
  double get edgeOffset;

  /// [FastRefresh] 参数更新时同步到 notifier。
  void _update({
    FastRefreshIndicator? indicator,
    bool? canProcessAfterNoMore,
    Axis? triggerAxis,
    FutureOr Function()? task,
    bool? waitTaskRefresh,
    bool? isNested,
  }) {
    if (indicator != null) {
      if (indicator.listenable == _indicator.listenable) {
        indicator.listenable?._rebind(this);
      } else {
        _indicator.listenable?._unbind();
        indicator.listenable?._bind(this);
      }
      if (indicator != _indicator) {
        _indicator = indicator;
      }
    }
    _canProcessAfterNoMore = canProcessAfterNoMore ?? _canProcessAfterNoMore;
    _triggerAxis = triggerAxis;
    _task = task;
    _waitTaskResult = waitTaskRefresh ?? _waitTaskResult;
    if (_indicator.clamping && _clampingAnimationController == null) {
      _initClampingAnimation();
    } else if (!_indicator.clamping && _clampingAnimationController != null) {
      _clampingAnimationController?.stop();
      _clampingAnimationController?.dispose();
      _clampingAnimationController = null;
    }
    if (isNested != null) {
      _isNested = isNested;
    }
    notifyListeners();
  }

  /// 重置部分状态（例如清掉 `noMore`）。
  void _reset() {
    if (_result == FastRefreshResult.noMore) {
      _result = FastRefreshResult.none;
    }
  }

  /// 编程触发任务：滚过触发位后再由弹簧吸回。
  ///
  /// [overOffset] 超出触发距离的额外偏移，必须大于 0。
  /// [force] 为 `true` 时即使任务进行中也强制执行。
  Future callTask({
    required double overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    if (!_mounted) {
      return Future.value();
    }
    if (!force) {
      if (modeLocked || noMoreLocked || secondaryLocked || !_canProcess) {
        return Future.value();
      }
    } else {
      _offset = 0;
      _mode = FastRefreshMode.inactive;
      _processing = false;
    }
    return animateToOffset(
      offset: actualTriggerOffset + overOffset,
      mode: FastRefreshMode.ready,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
    );
  }

  /// clamping 动画每一帧：更新 offset 并推进状态机。
  void _clampingTick() {
    final mOffset = calculateOffsetWithPixels(
        position, _clampingAnimationController!.value);
    if (hasSecondary &&
        !noMoreLocked &&
        mOffset > secondaryDimension &&
        _mode == FastRefreshMode.secondaryReady) {
      // 二楼完全打开后停动画。
      _offset = secondaryDimension;
      _clampingAnimationController!.stop();
    } else {
      // 禁止 ready 弹簧越过触发位。
      if (_mode == FastRefreshMode.ready &&
          !_indicator.springRebound &&
          mOffset < actualTriggerOffset) {
        _offset = actualTriggerOffset;
        _clampingAnimationController!.stop();
      } else {
        if (mOffset < 0) {
          _offset = 0;
          _clampingAnimationController!.stop();
        }
        _offset = mOffset;
      }
    }
    _slightDeviation();
    _updateMode();
    notifyListeners();
  }

  /// 惯性模拟创建时更新速度、轴与偏移。
  void _updateBySimulation(ScrollMetrics position, double velocity) {
    _velocity = velocity;
    // 轴变化时下一帧通知，避免布局中 setState。
    if (_axis != position.axis || _axisDirection != position.axisDirection) {
      _axis = position.axis;
      _axisDirection = position.axisDirection;
      Future(() {
        if (_mounted) {
          notifyListeners();
        }
      });
    }
    this.position = position;
    final oldMode = _mode;
    // 松手后按当前像素重算偏移。
    _updateOffset(position, position.pixels, true);
    // clamping 且仍越界时，用动画收回到 overExtent。
    if (clamping &&
        _offset > 0 &&
        ((_indicator.triggerWhenRelease && oldMode == FastRefreshMode.armed) ||
            !(modeLocked || secondaryLocked))) {
      final simulation = createBallisticSimulation(position, velocity);
      if (simulation != null) {
        _startClampingAnimation(simulation);
      }
    }
  }

  /// 把接近触发位的偏移吸附到精确值，避免弹簧停在 70.01 之类的位置。
  void _slightDeviation() {
    final double tolerance =
        _mode == FastRefreshMode.ready && !userOffsetNotifier.value
            ? 1.0
            : precisionErrorTolerance;
    if ((_offset - actualTriggerOffset).abs() <= tolerance) {
      _offset = actualTriggerOffset;
    }
  }

  /// 根据滚动位置更新越界偏移并驱动状态机。
  void _updateOffset(ScrollMetrics position, double value, bool bySimulation) {
    // clamping 且任务进行中 / 二楼锁定时不改 offset。
    if (clamping && (modeLocked || secondaryLocked)) {
      return;
    }
    // clamping 松手后的回弹由动画接管，这里不再写 offset。
    if ((clamping && _mode == FastRefreshMode.done && bySimulation) ||
        (!userOffsetNotifier.value &&
            clamping &&
            _offset > 0 &&
            !bySimulation)) {
      return;
    }
    this.position = position;
    // 记录旧值，判断是否需要通知。
    final oldOffset = _offset;
    final oldMode = _mode;
    // 计算并写入新偏移。
    _offset = _calculateOffset(position, value);
    _slightDeviation();
    // 未越界：仅无限加载 / 结束态需要继续走状态机。
    if (oldOffset == 0 && _offset == 0) {
      if (_mode == FastRefreshMode.done ||
          // 无限滚动。
          (infiniteOffset != null &&
              (!(_isNested && position.isNestedOuter) &&
                  edgeOffset < infiniteOffset!) &&
              !bySimulation &&
              !_infiniteExclude(position, value))) {
        // 更新模式。
        _updateMode(oldOffset);
        notifyListeners();
      }
      if (_indicator.notifyWhenInvisible && !bySimulation) {
        notifyListeners();
      }
      return;
    }
    // 更新模式。
    _updateMode(oldOffset);
    // 无变化则不通知。
    if (oldOffset == _offset && oldMode == _mode) {
      return;
    }
    // 触觉反馈。
    if (hapticFeedback && userOffsetNotifier.value) {
      if (_indicator.triggerWhenReach) {
        if (_mode == FastRefreshMode.processing &&
            oldMode == FastRefreshMode.drag) {
          HapticFeedback.mediumImpact();
        }
      } else {
        if (_mode == FastRefreshMode.armed &&
            oldMode != FastRefreshMode.armed) {
          HapticFeedback.mediumImpact();
        }
      }
    }
    // 惯性模拟期间避免在绘制中同步 setState。
    if (bySimulation) {
      // 内容高度变化时延迟通知。
      if (_offset <= actualTriggerOffset) {
        Future(() {
          if (_mounted) {
            notifyListeners();
          }
        });
      }
      return;
    }
    notifyListeners();
  }

  /// 按偏移推进有限状态机。
  void _updateMode([double? oldOffset]) {
    // 轴不匹配则不改模式。
    if (!_isSupportAxis) {
      return;
    }
    // 没有任务时保持 inactive。
    if (_task == null) {
      if (_mode != FastRefreshMode.inactive) {
        _mode = FastRefreshMode.inactive;
      }
      return;
    }
    // 任务执行中、完成后、noMore / 二楼锁定时不改主流程。
    if (!(modeLocked || noMoreLocked || secondaryLocked)) {
      // 当前不允许执行任务。
      if (!_canProcess) {
        _mode = FastRefreshMode.inactive;
        return;
      }
      // 无限滚动：靠近边缘即进入 processing。
      if (infiniteOffset != null &&
          (!(_isNested && position.isNestedOuter) &&
              edgeOffset < infiniteOffset!)) {
        if (_mode == FastRefreshMode.done &&
            position.maxScrollExtent != position.minScrollExtent) {
          if ((_result == FastRefreshResult.fail ||
                  (_result == FastRefreshResult.noMore &&
                      _canProcessAfterNoMore)) &&
              oldOffset != null &&
              oldOffset < _offset) {
            // 失败或允许再次加载时，继续往下拉则重试。
            _result = FastRefreshResult.none;
            _mode = FastRefreshMode.processing;
          } else {
            // 结束动画未完成，保持 done。
            return;
          }
        } else {
          if (_mode == FastRefreshMode.done) {
            if (offset == 0) {
              _mode = FastRefreshMode.inactive;
            }
          } else {
            _result = FastRefreshResult.none;
            _mode = FastRefreshMode.processing;
          }
        }
      } else if (_mode == FastRefreshMode.done && offset > 0) {
        // 结束动画未完成，保持 done。
        return;
      } else if (_offset == 0) {
        if (!(_mode == FastRefreshMode.ready && !userOffsetNotifier.value)) {
          // ready 回弹过程中不要被改回 drag / inactive。
          _mode = FastRefreshMode.inactive;
          if (_result != FastRefreshResult.noMore || _canProcessAfterNoMore) {
            _result = FastRefreshResult.none;
          }
          _releaseOffset = 0;
        }
      } else if (_offset < actualTriggerOffset) {
        if (_canProcessAfterNoMore &&
            _result == FastRefreshResult.noMore &&
            userOffsetNotifier.value) {
          _result = FastRefreshResult.none;
        }
        if (!(_mode == FastRefreshMode.ready && !userOffsetNotifier.value)) {
          // ready 回弹过程中不要被改回 drag / inactive。
          _mode = FastRefreshMode.drag;
        }
      } else if (_offset == actualTriggerOffset) {
        // 刚好停在触发位。
        if (userOffsetNotifier.value) {
          if (_indicator.triggerWhenReach) {
            _mode = FastRefreshMode.processing;
          } else {
            _mode = (_releaseOffset > actualTriggerOffset
                ? FastRefreshMode.ready
                : FastRefreshMode.armed);
          }
        } else {
          _mode = FastRefreshMode.processing;
        }
      } else if (_offset > actualTriggerOffset) {
        if (hasSecondary &&
            _offset >= actualSecondaryTriggerOffset &&
            (_releaseOffset == 0 ||
                _releaseOffset >= actualSecondaryTriggerOffset)) {
          // 二楼。
          if (_offset < secondaryDimension) {
            _mode = userOffsetNotifier.value
                ? FastRefreshMode.secondaryArmed
                : FastRefreshMode.secondaryReady;
          } else {
            _mode = userOffsetNotifier.value
                ? FastRefreshMode.secondaryReady
                : FastRefreshMode.secondaryOpen;
          }
        } else {
          // 普通刷新 / 加载。
          // 手指未离开：只武装，不执行任务。
          if (userOffsetNotifier.value) {
            _mode = _indicator.triggerWhenReach
                ? FastRefreshMode.processing
                : FastRefreshMode.armed;
          } else {
            if (_releaseOffset > actualTriggerOffset) {
              if (_indicator.triggerWhenReleaseNoWait) {
                // 松手立刻触发且不等待，直接进入 done。
                if (_task != null) {
                  Future.sync(_task!);
                }
                _mode = FastRefreshMode.done;
              } else if (_indicator.triggerWhenRelease) {
                // 松手立刻进入 processing。
                _mode = FastRefreshMode.processing;
              } else {
                _mode = FastRefreshMode.ready;
              }
            } else {
              _mode = FastRefreshMode.armed;
            }
          }
        }
      }
      // 进入 processing 后执行任务。
      if (_mode == FastRefreshMode.processing) {
        _onTask();
      }
    }
    // 二楼关闭：距边缘超过关闭距离则进入 closing。
    if (secondaryLocked) {
      _mode = secondaryDimension - _offset >= secondaryCloseTriggerOffset
          ? FastRefreshMode.secondaryClosing
          : FastRefreshMode.secondaryOpen;
      if (_offset == 0) {
        _mode = FastRefreshMode.inactive;
      }
    }
  }

  /// 执行任务并写入结果；抛错记为 fail，不向外抛。
  void _onTask() async {
    if (!(_canProcess && !_processing && _task != null)) {
      return;
    }
    _processing = true;
    if (_waitTaskResult) {
      try {
        final res = await Future.sync(_task!);
        if (res is FastRefreshResult) {
          _result = res;
        } else {
          _result = FastRefreshResult.success;
        }
      } catch (_) {
        _result = FastRefreshResult.fail;
      } finally {
        _setMode(FastRefreshMode.processed);
        _processing = false;
      }
    } else {
      Future.sync(_task!);
    }
  }

  /// 由控制器结束任务并写入 [result]。
  void _finishTask([FastRefreshResult result = FastRefreshResult.success]) {
    _result = result;
    if (!_waitTaskResult && mode == FastRefreshMode.processing) {
      _setMode(FastRefreshMode.processed);
      _processing = false;
    }
  }

  /// 启动 clamping 回弹动画。
  void _startClampingAnimation(Simulation simulation) {
    if (!clamping) {
      return;
    }
    if (_clampingAnimationController == null) {
      _initClampingAnimation();
    }
    if (_offset <= 0 || _clampingAnimationController!.isAnimating) {
      return;
    }
    _clampingAnimationController!.animateWith(simulation);
  }

  /// 重新走一次惯性模拟（任务结束后回弹、编程触发后吸位）。
  void _resetBallistic() {
    if (!_mounted) {
      return;
    }
    ScrollActivityDelegate? delegate;
    double velocity = 0;
    if (_position is ScrollPosition) {
      // ignore: invalid_use_of_protected_member
      final activity = (_position as ScrollPosition).activity;
      delegate = activity?.delegate;
      velocity = activity?.velocity ?? 0;
    } else if (_position is ScrollActivityDelegate) {
      delegate = _position as ScrollActivityDelegate;
    }
    if (delegate != null) {
      delegate.goBallistic(velocity);
    } else {
      if (clamping && _offset > 0 && !(modeLocked || secondaryLocked)) {
        final simulation = createBallisticSimulation(position, velocity);
        if (simulation != null) {
          _startClampingAnimation(simulation);
        }
      }
    }
  }

  /// 内部改模式并通知。
  void _setMode(FastRefreshMode mode) {
    if (_mode == mode) {
      return;
    }
    // 已卸载则忽略。
    if (!_mounted) {
      return;
    }
    final oldMode = _mode;
    _mode = mode;
    notifyListeners();
    // 进入 processed 后安排完成态收尾。
    if (this.mode == FastRefreshMode.processed) {
      _scheduleProcessedCompletion(oldMode);
      // 用户还按着时，下一帧按当前像素重算偏移。
      if (!clamping && userOffsetNotifier.value) {
        Future(() {
          if (!_mounted || _position == null) {
            return;
          }
          _updateOffset(position, position.pixels, false);
        });
      }
    }
  }

  /// 按 [processedDuration] 延迟进入完成态收尾。
  void _scheduleProcessedCompletion(FastRefreshMode oldMode) {
    if (processedDuration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _completeProcessedMode(oldMode);
      });
      return;
    }
    Future.delayed(processedDuration, () {
      _completeProcessedMode(oldMode);
    });
  }

  /// processed 停留结束：进入 done，必要时触发回弹。
  void _completeProcessedMode(FastRefreshMode oldMode) {
    if (!_mounted) {
      return;
    }
    if (mode != FastRefreshMode.processed) {
      return;
    }
    _syncFooterOffsetAfterProcessed();
    _setMode(FastRefreshMode.done);
    if (offset == 0) {
      _setMode(FastRefreshMode.inactive);
    }
    // 任务刚结束且已松手：只在仍越界时重瞄回弹。
    // 上拉加载后列表变高，用户已经回到范围内时不要 goBallistic，
    // 否则会打断正在滑的惯性。
    if (oldMode == FastRefreshMode.processing &&
        !userOffsetNotifier.value &&
        _shouldResetBallisticAfterProcessed()) {
      _resetBallistic();
    }
  }

  /// processed 收尾后是否还要重建惯性。范围内的惯性应继续，不要掐断。
  bool _shouldResetBallisticAfterProcessed() {
    if (clamping && _offset > 0) {
      return true;
    }
    if (_position == null) {
      return _offset > 0;
    }
    return _position!.outOfRange || _offset > precisionErrorTolerance;
  }

  /// Footer 完成后按当前像素重算偏移，避免内容高度变化后指示器悬空。
  void _syncFooterOffsetAfterProcessed() {
    if (!_mounted ||
        _offset == 0 ||
        _position == null ||
        _position!.outOfRange ||
        this is! FastRefreshFooterNotifier) {
      return;
    }
    final oldOffset = _offset;
    if (!clamping) {
      _offset = _calculateOffset(_position!, _position!.pixels);
    }
    if (_offset != oldOffset) {
      notifyListeners();
    }
  }

  /// 生成当前快照；轴未就绪时为 `null`。
  FastRefreshIndicatorState? get indicatorState {
    if (_axis == null || _axisDirection == null) {
      return null;
    }
    return FastRefreshIndicatorState(
      indicator: _indicator,
      userOffsetNotifier: userOffsetNotifier,
      notifier: this,
      mode: mode,
      result: _result,
      offset: offset,
      safeOffset: safeOffset,
      axis: _axis!,
      axisDirection: _axisDirection!,
      viewportDimension: viewportDimension,
      actualTriggerOffset: actualTriggerOffset,
    );
  }

  /// 构建指示器；轴未就绪或不支持时返回空。
  Widget _build(BuildContext context) {
    if (_axis == null || _axisDirection == null) {
      return const SizedBox();
    }
    if (!_isSupportAxis) {
      return const SizedBox();
    }
    return _indicator.build(
      context,
      indicatorState!,
    );
  }
}

/// 指示器内部用的 ValueListenable，把 notifier 变化转发给组件。
class _IndicatorListenable<T extends FastRefreshNotifier>
    extends ValueListenable<T> {
  /// 被监听的 notifier。
  final T _indicatorNotifier;

  /// 包装 [indicatorNotifier]。
  _IndicatorListenable(this._indicatorNotifier);

  /// 外部监听者。
  final List<VoidCallback> _listeners = [];
  final _DeferredListenerGate _gate = _DeferredListenerGate();

  /// 转发通知。layout 期间改到帧后，避免指示器 [setState] 崩帧。
  void _onNotify() {
    _gate.run(_listeners);
  }

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      _indicatorNotifier.addListener(_onNotify);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _indicatorNotifier.removeListener(_onNotify);
    }
  }

  /// 被包装的 notifier。
  @override
  T get value => _indicatorNotifier;
}

/// Header 状态机：顶部越界偏移与刷新任务。
class FastRefreshHeaderNotifier extends FastRefreshNotifier {
  /// 创建 Header notifier。
  FastRefreshHeaderNotifier({
    required FastRefreshHeader header,
    required super.userOffsetNotifier,
    required super.vsync,
    required CanProcessCallBack onCanRefresh,
    super.canProcessAfterNoMore = false,
    super.isNested = false,
    bool canProcessAfterFail = true,
    super.triggerAxis,
    FutureOr Function()? onRefresh,
    bool waitRefreshResult = true,
  }) : super(
          indicator: header,
          onCanProcess: onCanRefresh,
          task: onRefresh,
          waitTaskResult: waitRefreshResult,
        );

  /// 由目标像素计算 Header 越界：clamping 时累加 / 扣减已有 offset。
  @override
  double _calculateOffset(ScrollMetrics position, double value) {
    if (value >= position.minScrollExtent &&
        _offset != 0 &&
        !(clamping && _offset > 0)) {
      return 0;
    }
    // 相对顶部的移动距离。
    final move = position.minScrollExtent - value;
    if (clamping) {
      if (value > position.minScrollExtent) {
        // 回弹时先从已有 offset 扣减。
        return math.max(_offset > 0 ? (move + _offset) : 0, 0);
      } else {
        // 越界时累加 offset。
        final mOffset = move + _offset;
        if (hasSecondary && mOffset > secondaryDimension) {
          // 不能超过二楼高度。
          return secondaryDimension;
        }
        // 越界上限。
        if (actualMaxOverOffset != double.infinity) {
          return math.min(mOffset, actualMaxOverOffset);
        }
        return mOffset;
      }
    } else {
      return value > position.minScrollExtent ? 0 : move;
    }
  }

  /// 顶部越界：`minScrollExtent - pixels`。
  @override
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels) =>
      math.max(position.minScrollExtent - pixels, 0.0);

  /// Header 的 clamping / 越界回弹模拟。
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final mVelocity =
        hasSecondary && !noMoreLocked && _offset >= actualSecondaryTriggerOffset
            ? -secondaryVelocity
            : velocity;
    if (_offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position:
            clamping ? position.minScrollExtent - _offset : position.pixels,
        velocity: mVelocity,
        leadingExtent: position.minScrollExtent - overExtent,
        trailingExtent: 0,
        tolerance: _physics.toleranceFor(position),
      );
    }
    return null;
  }

  /// 距顶部的距离。
  @override
  double get edgeOffset => position.pixels;

  /// 碰到底部时不走 Header 无限滚动。
  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value >= position.maxScrollExtent;
  }

  /// 滚到顶部外侧 [offset]；[duration] 为 `null` 时 [jumpTo]。
  @override
  Future animateToOffset({
    required double offset,
    required FastRefreshMode mode,
    bool jumpToEdge = true,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  }) async {
    final effectivePosition = _effectiveScrollPosition();
    if (effectivePosition == null) {
      return;
    }
    final matchedController =
        _matchingScrollController(scrollController, effectivePosition);
    // 顶部外侧：像素为负。
    final scrollTo = -offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      // 先落到顶部边缘，再向外拉出目标偏移。
      if (matchedController != null) {
        matchedController.jumpTo(effectivePosition.minScrollExtent);
      } else {
        effectivePosition.jumpTo(effectivePosition.minScrollExtent);
      }
    }
    if (clamping) {
      // clamping：列表不越界，只动画指示器 offset。
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(effectivePosition, 0);
      } else {
        userOffsetNotifier.value = true;
        _clampingAnimationController!.value = effectivePosition.minScrollExtent;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(effectivePosition, 0);
      }
    } else {
      // bouncing：列表真实滚到外侧像素。
      if (duration == null) {
        if (matchedController != null) {
          matchedController.jumpTo(scrollTo);
        } else {
          effectivePosition.jumpTo(scrollTo);
        }
      } else {
        userOffsetNotifier.value = true;
        if (matchedController != null) {
          await matchedController.animateTo(scrollTo,
              duration: duration, curve: curve);
        } else {
          await effectivePosition.animateTo(scrollTo,
              duration: duration, curve: curve);
        }
        userOffsetNotifier.value = false;
        notifyListeners();
        // 动画结束后走弹簧，把位置吸到触发位再进入 processing。
        _resetBallistic();
      }
    }
  }
}

/// Footer 状态机：底部越界偏移与加载任务。
class FastRefreshFooterNotifier extends FastRefreshNotifier {
  /// 创建 Footer notifier。
  FastRefreshFooterNotifier({
    required FastRefreshFooter footer,
    required super.userOffsetNotifier,
    required super.vsync,
    required CanProcessCallBack onCanLoad,
    super.canProcessAfterNoMore = false,
    super.isNested = false,
    bool canProcessAfterFail = true,
    super.triggerAxis,
    FutureOr Function()? onLoad,
    bool waitLoadResult = true,
  }) : super(
          indicator: footer,
          onCanProcess: onCanLoad,
          task: onLoad,
          waitTaskResult: waitLoadResult,
        );

  /// 内容未撑满时，无限加载不保持越界。
  @override
  double get overExtent {
    if (infiniteOffset != null &&
        position.maxScrollExtent <= position.minScrollExtent) {
      return 0;
    }
    return super.overExtent;
  }

  /// 由目标像素计算 Footer 越界：clamping 时累加 / 扣减已有 offset。
  @override
  double _calculateOffset(ScrollMetrics position, double value) {
    if (value <= position.maxScrollExtent &&
        _offset != 0 &&
        !(clamping && _offset > 0)) {
      return 0;
    }
    // 相对底部的移动距离。
    final move = value - position.maxScrollExtent;
    if (clamping) {
      if (value < position.maxScrollExtent) {
        // 回弹时先从已有 offset 扣减。
        return math.max(_offset > 0 ? (move + _offset) : 0, 0);
      } else {
        // 越界时累加 offset。
        final mOffset = move + _offset;
        if (hasSecondary && mOffset > secondaryDimension) {
          // 不能超过二楼高度。
          return secondaryDimension;
        }
        // 越界上限。
        if (actualMaxOverOffset != double.infinity) {
          return math.min(mOffset, actualMaxOverOffset);
        }
        return mOffset;
      }
    } else {
      return value < position.maxScrollExtent ? 0 : move;
    }
  }

  /// 底部越界：`pixels - maxScrollExtent`。
  @override
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels) =>
      math.max(pixels - position.maxScrollExtent, 0.0);

  /// Footer 的 clamping / 越界回弹模拟。
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final mVelocity =
        hasSecondary && !noMoreLocked && _offset >= actualSecondaryTriggerOffset
            ? secondaryVelocity
            : velocity;
    if (_offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position:
            clamping ? position.maxScrollExtent + _offset : position.pixels,
        velocity: mVelocity,
        leadingExtent: 0,
        trailingExtent: position.maxScrollExtent + overExtent,
        tolerance: _physics.toleranceFor(position),
      );
    }
    return null;
  }

  /// 距底部的距离。
  @override
  double get edgeOffset => position.maxScrollExtent - position.pixels;

  /// 碰到顶部时不走 Footer 无限滚动。
  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value <= position.minScrollExtent;
  }

  /// 滚到底部外侧 [offset]；[duration] 为 `null` 时 [jumpTo]。
  @override
  Future animateToOffset({
    required double offset,
    required FastRefreshMode mode,
    Duration? duration,
    Curve curve = Curves.linear,
    bool jumpToEdge = true,
    ScrollController? scrollController,
  }) async {
    final effectivePosition = _effectiveScrollPosition();
    if (effectivePosition == null) {
      return;
    }
    final matchedController =
        _matchingScrollController(scrollController, effectivePosition);
    // 底部外侧：像素 = 最大滚动范围 + 越界距离。
    final scrollTo = effectivePosition.maxScrollExtent + offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      // 先落到底部边缘，再向外拉出目标偏移。
      if (matchedController != null) {
        matchedController.jumpTo(effectivePosition.maxScrollExtent);
      } else {
        effectivePosition.jumpTo(effectivePosition.maxScrollExtent);
      }
    }
    if (clamping) {
      // clamping：列表不越界，只动画指示器 offset。
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(effectivePosition, 0);
      } else {
        userOffsetNotifier.value = true;
        _clampingAnimationController!.value = effectivePosition.maxScrollExtent;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(effectivePosition, 0);
      }
    } else {
      // bouncing：列表真实滚到外侧像素。
      if (duration == null) {
        if (matchedController != null) {
          matchedController.jumpTo(scrollTo);
        } else {
          effectivePosition.jumpTo(scrollTo);
        }
      } else {
        userOffsetNotifier.value = true;
        if (matchedController != null) {
          await matchedController.animateTo(scrollTo,
              duration: duration, curve: curve);
        } else {
          await effectivePosition.animateTo(scrollTo,
              duration: duration, curve: curve);
        }
        userOffsetNotifier.value = false;
        notifyListeners();
        // 动画结束后走弹簧，把位置吸到触发位再进入 processing。
        _resetBallistic();
      }
    }
  }
}
