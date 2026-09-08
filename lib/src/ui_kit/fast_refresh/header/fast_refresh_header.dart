part of '../fast_refresh.dart';

/// 顶部刷新指示器基类。
abstract class FastRefreshHeader extends FastRefreshIndicator {
  /// 创建 Header 配置。参数含义见 [FastRefreshIndicator]。
  const FastRefreshHeader({
    required super.triggerOffset,
    required super.clamping,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.position,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.listenable,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  });
}

/// 用回调构建的 Header。
class FastBuilderHeader extends FastRefreshHeader {
  /// 根据快照构建组件。
  final FastRefreshIndicatorBuilder builder;

  /// 创建回调 Header。默认 [triggerOffset] 为 70、[clamping] 为 `false`。
  const FastBuilderHeader({
    required this.builder,
    super.triggerOffset = 70,
    super.clamping = false,
    super.position = FastRefreshIndicatorPosition.above,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.listenable,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  });

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return builder(context, state);
  }
}

/// 只监听状态、不绘制自身的 Header。需配合 [FastRefreshStateListenable]。
class FastListenerHeader extends FastRefreshHeader {
  /// 创建监听 Header。[position] 固定为 [FastRefreshIndicatorPosition.custom]。
  const FastListenerHeader({
    required FastRefreshStateListenable super.listenable,
    required super.triggerOffset,
    super.clamping = true,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  }) : super(
          position: FastRefreshIndicatorPosition.custom,
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return const SizedBox();
  }
}

/// 给已有 Header 叠上二楼能力。
abstract class FastSecondaryHeader extends FastRefreshHeader {
  /// 被包装的原 Header。
  final FastRefreshHeader header;

  /// 用 [header] 的配置叠加二楼参数。
  FastSecondaryHeader({
    required this.header,
    required double super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    FastRefreshStateListenable? listenable,
  }) : super(
          triggerOffset: header.triggerOffset,
          clamping: header.clamping,
          processedDuration: header.processedDuration,
          spring: header.spring,
          horizontalSpring: header.horizontalSpring,
          readySpringBuilder: header.readySpringBuilder,
          horizontalReadySpringBuilder: header.horizontalReadySpringBuilder,
          springRebound: header.springRebound,
          frictionFactor: header.frictionFactor,
          horizontalFrictionFactor: header.horizontalFrictionFactor,
          safeArea: header.safeArea,
          infiniteOffset: header.infiniteOffset,
          hitOver: header.hitOver,
          infiniteHitOver: header.infiniteHitOver,
          position: header.position,
          hapticFeedback: header.hapticFeedback,
          notifyWhenInvisible: header.notifyWhenInvisible,
          listenable: listenable ?? header.listenable,
          triggerWhenReach: header.triggerWhenReach,
          triggerWhenRelease: header.triggerWhenRelease,
          triggerWhenReleaseNoWait: header.triggerWhenReleaseNoWait,
          maxOverOffset: header.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return secondaryBuild(context, state, header);
  }

  /// 同时构建原 Header 与二楼内容。
  Widget secondaryBuild(
      BuildContext context, FastRefreshIndicatorState state, FastRefreshIndicator indicator);
}

/// 用回调构建二楼 Header。
class FastSecondaryBuilderHeader extends FastSecondaryHeader {
  /// 二楼构建器。
  final FastRefreshSecondaryIndicatorBuilder builder;

  /// 创建回调二楼 Header。
  FastSecondaryBuilderHeader({
    required super.header,
    required this.builder,
    required super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.listenable,
  });

  @override
  Widget secondaryBuild(
      BuildContext context, FastRefreshIndicatorState state, FastRefreshIndicator indicator) {
    return builder(context, state, indicator);
  }
}

/// [FastRefresh.onRefresh] 为 `null` 时使用：保留越界手感，不画指示器。
class FastNotRefreshHeader extends FastRefreshHeader {
  /// 创建不可见 Header：触发距离为 0，不执行刷新任务。
  const FastNotRefreshHeader({
    super.clamping = false,
    super.position = FastRefreshIndicatorPosition.custom,
    super.spring,
    super.horizontalSpring,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.hitOver,
    super.maxOverOffset,
  }) : super(
          triggerOffset: 0,
          infiniteOffset: null,
          processedDuration: const Duration(seconds: 0),
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return const SizedBox();
  }
}

/// 覆盖已有 Header 的部分参数。请确认覆盖后行为仍然正确。
class FastOverrideHeader extends FastRefreshHeader {
  /// 被覆盖的原 Header，[build] 仍委托给它。
  final FastRefreshHeader header;

  /// 未传的参数沿用 [header]，[build] 仍委托给原 Header。
  FastOverrideHeader({
    required this.header,
    double? triggerOffset,
    bool? clamping,
    FastRefreshIndicatorPosition? position,
    Duration? processedDuration,
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
    FastRefreshSpringBuilder? readySpringBuilder,
    FastRefreshSpringBuilder? horizontalReadySpringBuilder,
    bool? springRebound,
    FastRefreshFrictionFactor? frictionFactor,
    FastRefreshFrictionFactor? horizontalFrictionFactor,
    bool? safeArea,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool? hapticFeedback,
    double? secondaryTriggerOffset,
    double? secondaryVelocity,
    double? secondaryDimension,
    double? secondaryCloseTriggerOffset,
    bool? notifyWhenInvisible,
    FastRefreshStateListenable? listenable,
    bool? triggerWhenReach,
    bool? triggerWhenRelease,
    bool? triggerWhenReleaseNoWait,
    double? maxOverOffset,
  }) : super(
          triggerOffset: triggerOffset ?? header.triggerOffset,
          clamping: clamping ?? header.clamping,
          processedDuration: processedDuration ?? header.processedDuration,
          spring: spring ?? header.spring,
          horizontalSpring: horizontalSpring ?? header.horizontalSpring,
          readySpringBuilder: readySpringBuilder ?? header.readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder ??
              header.horizontalReadySpringBuilder,
          springRebound: springRebound ?? header.springRebound,
          frictionFactor: frictionFactor ?? header.frictionFactor,
          horizontalFrictionFactor:
              horizontalFrictionFactor ?? header.horizontalFrictionFactor,
          safeArea: safeArea ?? header.safeArea,
          infiniteOffset: infiniteOffset ?? header.infiniteOffset,
          hitOver: hitOver ?? header.hitOver,
          infiniteHitOver: infiniteHitOver ?? header.infiniteHitOver,
          position: position ?? header.position,
          hapticFeedback: hapticFeedback ?? header.hapticFeedback,
          secondaryTriggerOffset:
              secondaryTriggerOffset ?? header.secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity ?? header.secondaryVelocity,
          secondaryDimension: secondaryDimension ?? header.secondaryDimension,
          secondaryCloseTriggerOffset:
              secondaryCloseTriggerOffset ?? header.secondaryCloseTriggerOffset,
          notifyWhenInvisible:
              notifyWhenInvisible ?? header.notifyWhenInvisible,
          listenable: listenable ?? header.listenable,
          triggerWhenReach: triggerWhenReach ?? header.triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease ?? header.triggerWhenRelease,
          triggerWhenReleaseNoWait:
              triggerWhenReleaseNoWait ?? header.triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset ?? header.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return header.build(context, state);
  }
}
