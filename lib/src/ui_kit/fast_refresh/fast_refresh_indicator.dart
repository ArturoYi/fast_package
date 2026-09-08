part of 'fast_refresh.dart';

/// 二楼默认打开速度。
const kDefaultSecondaryVelocity = 3000.0;

/// 二楼默认关闭触发距离。
const kDefaultSecondaryCloseTriggerOffset = 70.0;

/// 按当前模式与偏移构建弹簧。
///
/// [mode] 指示器模式。
/// [offset] 当前越界偏移。
/// [actualTriggerOffset] 实际触发距离（含安全区）。
/// [velocity] 当前滚动速度。
typedef FastRefreshSpringBuilder = physics.SpringDescription Function({
  required FastRefreshMode mode,
  required double offset,
  required double actualTriggerOffset,
  required double velocity,
});

/// Header / Footer 的生命周期。
enum FastRefreshMode {
  /// 默认隐藏，没有任何触发条件。任务走完整流程后回到此态。
  inactive,

  /// 已越界，但未达到触发距离。此时松手会回弹，不执行任务。
  drag,

  /// 已越过触发距离，尚未松手。松手后进入 [ready] 并执行任务。
  armed,

  /// 用户已松手，弹簧正在吸到触发位，即将进入 [processing]。
  ready,

  /// 任务执行中，直到回调结束或 [FastRefreshController.finishRefresh] /
  /// [FastRefreshController.finishLoad] 被调用。
  processing,

  /// 任务已结束，但仍在展示完成态（成功 / 失败 / 无更多）。
  processed,

  /// 已越过二楼触发距离，尚未松手。
  secondaryArmed,

  /// 已松手，即将打开二楼。
  secondaryReady,

  /// 二楼已打开。
  secondaryOpen,

  /// 二楼正在关闭。
  secondaryClosing,

  /// 完成态结束，等待回弹；回弹结束后回到 [inactive]。
  done,
}

/// 任务完成后的结果。
enum FastRefreshResult {
  /// 尚未触发任务，或已回到 [FastRefreshMode.inactive] 后被清空。
  none,

  /// 成功。
  success,

  /// 失败。
  fail,

  /// 没有更多数据。Footer 默认会锁定，直到 [FastRefreshController.resetFooter]。
  noMore,
}

/// 指示器在布局中的位置。
enum FastRefreshIndicatorPosition {
  /// 叠在内容之上（[Stack] 后绘制）。
  above,

  /// 叠在内容之下（[Stack] 先绘制）。
  behind,

  /// 由 [FastHeaderLocator] / [FastFooterLocator] 放进列表内部。
  locator,

  /// 完全自定义，[FastRefresh] 不再构建指示器组件。
  custom,
}

/// 传给 Header / Footer 构建器的即时快照。
class FastRefreshIndicatorState {
  /// 指示器配置。
  final FastRefreshIndicator indicator;

  /// 驱动该快照的 notifier。
  final FastRefreshNotifier notifier;

  /// 用户是否正在拖拽。`true` 表示手指未离开。
  final ValueNotifier<bool> userOffsetNotifier;

  /// 当前生命周期。
  final FastRefreshMode mode;

  /// 最近一次任务结果。
  final FastRefreshResult result;

  /// 当前越界偏移（像素）。
  final double offset;

  /// 安全区计入的额外距离。
  final double safeOffset;

  /// 滚动轴。
  final Axis axis;

  /// 滚动方向。
  final AxisDirection axisDirection;

  /// 视口尺寸。全屏指示器、二楼可用。
  final double viewportDimension;

  /// 配置上的触发距离，不含安全区。
  double get triggerOffset => indicator.triggerOffset;

  /// 实际触发距离：`triggerOffset + safeOffset`。
  final double actualTriggerOffset;

  /// 二楼触发距离；未启用二楼时为 `null`。
  double? get secondaryTriggerOffset => indicator.secondaryTriggerOffset;

  /// 实际二楼触发距离（含安全区）。
  double? get actualSecondaryTriggerOffset =>
      notifier.actualSecondaryTriggerOffset;

  /// 滚动方向是否反向（向上或向左）。
  bool get reverse =>
      axisDirection == AxisDirection.up || axisDirection == AxisDirection.left;

  /// 创建快照。
  const FastRefreshIndicatorState({
    required this.indicator,
    required this.notifier,
    required this.userOffsetNotifier,
    required this.mode,
    required this.result,
    required this.offset,
    required this.safeOffset,
    required this.axis,
    required this.axisDirection,
    required this.viewportDimension,
    required this.actualTriggerOffset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastRefreshIndicatorState &&
          runtimeType == other.runtimeType &&
          indicator == other.indicator &&
          notifier == other.notifier &&
          mode == other.mode &&
          result == other.result &&
          offset == other.offset &&
          safeOffset == other.safeOffset &&
          axis == other.axis &&
          axisDirection == other.axisDirection &&
          viewportDimension == other.viewportDimension &&
          actualTriggerOffset == other.actualTriggerOffset;

  @override
  int get hashCode =>
      indicator.hashCode ^
      notifier.hashCode ^
      mode.hashCode ^
      result.hashCode ^
      offset.hashCode ^
      safeOffset.hashCode ^
      axis.hashCode ^
      axisDirection.hashCode ^
      viewportDimension.hashCode ^
      actualTriggerOffset.hashCode;

  @override
  String toString() {
    return 'FastRefreshIndicatorState{indicator: $indicator, notifier: $notifier, userOffsetNotifier: $userOffsetNotifier, mode: $mode, result: $result, offset: $offset, safeOffset: $safeOffset, axis: $axis, axisDirection: $axisDirection, viewportDimension: $viewportDimension, actualTriggerOffset: $actualTriggerOffset}';
  }
}

/// 用当前快照构建 Header / Footer。
typedef FastRefreshIndicatorBuilder = Widget Function(
    BuildContext context, FastRefreshIndicatorState state);

/// 二楼指示器构建器。第三个参数是被包装的原指示器。
typedef FastRefreshSecondaryIndicatorBuilder = Widget Function(
    BuildContext context, FastRefreshIndicatorState state, FastRefreshIndicator indicator);

/// 在指示器组件外监听快照。
///
/// 把它传给 Header / Footer 的 [FastRefreshIndicator.listenable]，即可在任意位置
/// 用 [ValueListenableBuilder] 读取 [value]。
class FastRefreshStateListenable extends ValueListenable<FastRefreshIndicatorState?> {
  /// 绑定中的 notifier。
  FastRefreshNotifier? _indicatorNotifier;

  /// 外部监听者。
  final List<VoidCallback> _listeners = [];

  /// 绑定 notifier。已有监听者时会立刻补一次通知。
  void _bind(FastRefreshNotifier indicatorNotifier) {
    _indicatorNotifier = indicatorNotifier;
    if (_listeners.isNotEmpty) {
      indicatorNotifier.addListener(_onNotify);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _onNotify();
      });
    }
  }

  /// 解除绑定。
  void _unbind() {
    _indicatorNotifier?.removeListener(_onNotify);
    _indicatorNotifier = null;
  }

  /// 换绑到新的 notifier。
  void _rebind(FastRefreshNotifier indicatorNotifier) {
    if (_indicatorNotifier == indicatorNotifier) {
      return;
    }
    _unbind();
    _bind(indicatorNotifier);
  }

  /// 把 notifier 的变化转发给外部监听者。
  void _onNotify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      _indicatorNotifier?.addListener(_onNotify);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _indicatorNotifier?.removeListener(_onNotify);
    }
  }

  /// 当前快照。轴信息未就绪或未绑定时为 `null`。
  @override
  FastRefreshIndicatorState? get value => _indicatorNotifier?.indicatorState;

  /// 解绑并清空监听。可重复调用。
  void dispose() {
    _unbind();
    _listeners.clear();
  }
}

/// 刷新 / 加载指示器的配置与构建入口。
abstract class FastRefreshIndicator {
  /// 触发任务所需的越界距离。
  final double triggerOffset;

  /// 为 `true` 时列表不跟着越界，只移动指示器（类似 Material 刷新）。
  final bool clamping;

  /// 是否把安全区计入实际触发距离。
  final bool safeArea;

  /// [FastRefreshMode.processed] 的停留时长，之后进入回弹。
  final Duration processedDuration;

  /// 越界回弹弹簧。未设置时用物理默认弹簧。
  final physics.SpringDescription? spring;

  /// 横向滚动时的回弹弹簧。
  final physics.SpringDescription? horizontalSpring;

  /// [FastRefreshMode.ready] 时使用的弹簧（吸到触发位）。
  final FastRefreshSpringBuilder? readySpringBuilder;

  /// 横向 [FastRefreshMode.ready] 弹簧。
  final FastRefreshSpringBuilder? horizontalReadySpringBuilder;

  /// ready 弹簧是否允许越过触发位再回弹。仅对 [readySpringBuilder] 生效。
  final bool springRebound;

  /// 越界摩擦。见 [BouncingScrollPhysics.frictionFactor]。
  final FastRefreshFrictionFactor? frictionFactor;

  /// 横向越界摩擦。
  final FastRefreshFrictionFactor? horizontalFrictionFactor;

  /// 距边缘小于该值时自动触发（无限加载 / 刷新）。`null` 表示必须拉过阈值再松手。
  final double? infiniteOffset;

  /// 惯性滚动是否允许越界。仅在 [clamping] 为 `false` 时生效。
  /// 默认：启用了 [infiniteOffset] 则为 `true`。
  final bool hitOver;

  /// 无限滚动时惯性是否允许越过触发位继续越界。
  /// 默认：未启用 [infiniteOffset] 则为 `true`。
  final bool infiniteHitOver;

  /// 指示器绘制位置。
  final FastRefreshIndicatorPosition position;

  /// 到达 armed / processing 时是否触觉反馈。
  final bool hapticFeedback;

  /// 二楼触发距离，必须大于 [triggerOffset]。`null` 表示关闭二楼。
  final double? secondaryTriggerOffset;

  /// 二楼打开速度。
  final double secondaryVelocity;

  /// 二楼高度。默认等于视口高度。
  final double? secondaryDimension;

  /// 二楼关闭触发距离。
  final double secondaryCloseTriggerOffset;

  /// 指示器不可见（offset < 0）时是否仍通知。可能增加开销。
  final bool notifyWhenInvisible;

  /// 外部快照监听。
  final FastRefreshStateListenable? listenable;

  /// 到达 [triggerOffset] 立即触发，不必再松手。
  final bool triggerWhenReach;

  /// 越过 [triggerOffset] 后松手立即进入 [FastRefreshMode.processing]。
  final bool triggerWhenRelease;

  /// 越过 [triggerOffset] 后松手立刻触发任务，不等待任务结束，
  /// 模式直接进入 [FastRefreshMode.done]。适合同步事件或外部指示器。
  final bool triggerWhenReleaseNoWait;

  /// 越界上限。[double.infinity] 表示不限制。
  final double maxOverOffset;

  /// 创建指示器配置。
  const FastRefreshIndicator({
    required this.triggerOffset,
    required this.clamping,
    this.processedDuration = const Duration(seconds: 1),
    this.safeArea = true,
    this.spring,
    this.horizontalSpring,
    this.readySpringBuilder,
    this.horizontalReadySpringBuilder,
    this.springRebound = true,
    this.frictionFactor,
    this.horizontalFrictionFactor,
    this.infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    this.position = FastRefreshIndicatorPosition.above,
    this.secondaryTriggerOffset,
    this.hapticFeedback = false,
    this.secondaryVelocity = kDefaultSecondaryVelocity,
    this.secondaryDimension,
    this.secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    this.notifyWhenInvisible = false,
    this.listenable,
    this.triggerWhenReach = false,
    this.triggerWhenRelease = false,
    this.triggerWhenReleaseNoWait = false,
    this.maxOverOffset = double.infinity,
  })  : hitOver = hitOver ?? infiniteOffset != null,
        infiniteHitOver = infiniteHitOver ?? infiniteOffset == null,
        assert(infiniteOffset == null || infiniteOffset >= 0,
            'The infiniteOffset cannot be less than 0.'),
        assert(infiniteOffset == null || !clamping,
            'Cannot scroll indefinitely when clamping.'),
        assert(!(hitOver == false && infiniteOffset != null),
            'When hitOver is true, infinite scrolling cannot be used, please set infiniteHitOver.'),
        assert(
            secondaryTriggerOffset == null ||
                secondaryTriggerOffset > triggerOffset,
            'The secondaryTriggerOffset cannot be less than triggerOffset.'),
        assert(!(infiniteOffset != null && secondaryTriggerOffset != null),
            'Infinite scroll and secondary cannot be used together.'),
        assert(
            secondaryDimension == null ||
                secondaryDimension > (secondaryTriggerOffset ?? 0),
            'The secondaryDimension cannot be less than secondaryTriggerOffset.'),
        assert(maxOverOffset == double.infinity || maxOverOffset >= 0,
            'The maxOverOffset cannot be less than 0.');

  /// 根据 [state] 构建指示器组件。
  Widget build(BuildContext context, FastRefreshIndicatorState state);
}
