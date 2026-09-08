part of '../fast_refresh.dart';

/// 底部加载指示器基类。默认开启 [infiniteOffset]（距边缘 0 即触发）。
abstract class FastRefreshFooter extends FastRefreshIndicator {
  /// 创建 Footer 配置。参数含义见 [FastRefreshIndicator]。
  const FastRefreshFooter({
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
    super.infiniteOffset = 0,
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

/// 用回调构建的 Footer。
class FastBuilderFooter extends FastRefreshFooter {
  /// 根据快照构建组件。
  final FastRefreshIndicatorBuilder builder;

  /// 创建回调 Footer。默认 [triggerOffset] 为 70、[clamping] 为 `false`。
  const FastBuilderFooter({
    required this.builder,
    super.triggerOffset = 70,
    super.clamping = false,
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

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return builder(context, state);
  }
}

/// 只监听状态、不绘制自身的 Footer。需配合 [FastRefreshStateListenable]。
class FastListenerFooter extends FastRefreshFooter {
  /// 创建监听 Footer。[position] 固定为 [FastRefreshIndicatorPosition.custom]。
  const FastListenerFooter({
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

/// 给已有 Footer 叠上二楼能力。
abstract class FastSecondaryFooter extends FastRefreshFooter {
  /// 被包装的原 Footer。
  final FastRefreshFooter footer;

  /// 用 [footer] 的配置叠加二楼参数。
  FastSecondaryFooter({
    required this.footer,
    required double super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    FastRefreshStateListenable? listenable,
  }) : super(
          triggerOffset: footer.triggerOffset,
          clamping: footer.clamping,
          processedDuration: footer.processedDuration,
          spring: footer.spring,
          horizontalSpring: footer.horizontalSpring,
          readySpringBuilder: footer.readySpringBuilder,
          horizontalReadySpringBuilder: footer.horizontalReadySpringBuilder,
          springRebound: footer.springRebound,
          frictionFactor: footer.frictionFactor,
          horizontalFrictionFactor: footer.horizontalFrictionFactor,
          safeArea: footer.safeArea,
          infiniteOffset: footer.infiniteOffset,
          hitOver: footer.hitOver,
          infiniteHitOver: footer.infiniteHitOver,
          position: footer.position,
          hapticFeedback: footer.hapticFeedback,
          notifyWhenInvisible: footer.notifyWhenInvisible,
          listenable: listenable ?? footer.listenable,
          triggerWhenReach: footer.triggerWhenReach,
          triggerWhenRelease: footer.triggerWhenRelease,
          triggerWhenReleaseNoWait: footer.triggerWhenReleaseNoWait,
          maxOverOffset: footer.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return secondaryBuild(context, state, footer);
  }

  /// 同时构建原 Footer 与二楼内容。
  Widget secondaryBuild(
      BuildContext context, FastRefreshIndicatorState state, FastRefreshIndicator indicator);
}

/// 用回调构建二楼 Footer。
class FastSecondaryBuilderFooter extends FastSecondaryFooter {
  /// 二楼构建器。
  final FastRefreshSecondaryIndicatorBuilder builder;

  /// 创建回调二楼 Footer。
  FastSecondaryBuilderFooter({
    required super.footer,
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

/// [FastRefresh.onLoad] 为 `null` 时使用：保留越界手感，不画指示器。
class FastNotLoadFooter extends FastRefreshFooter {
  /// 创建不可见 Footer：触发距离为 0，不执行加载任务。
  const FastNotLoadFooter({
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

/// 覆盖已有 Footer 的部分参数。请确认覆盖后行为仍然正确。
class FastOverrideFooter extends FastRefreshFooter {
  /// 被覆盖的原 Footer，[build] 仍委托给它。
  final FastRefreshFooter footer;

  /// 未传的参数沿用 [footer]，[build] 仍委托给原 Footer。
  FastOverrideFooter({
    required this.footer,
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
          triggerOffset: triggerOffset ?? footer.triggerOffset,
          clamping: clamping ?? footer.clamping,
          processedDuration: processedDuration ?? footer.processedDuration,
          spring: spring ?? footer.spring,
          horizontalSpring: horizontalSpring ?? footer.horizontalSpring,
          readySpringBuilder: readySpringBuilder ?? footer.readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder ??
              footer.horizontalReadySpringBuilder,
          springRebound: springRebound ?? footer.springRebound,
          frictionFactor: frictionFactor ?? footer.frictionFactor,
          horizontalFrictionFactor:
              horizontalFrictionFactor ?? footer.horizontalFrictionFactor,
          safeArea: safeArea ?? footer.safeArea,
          infiniteOffset: infiniteOffset ?? footer.infiniteOffset,
          hitOver: hitOver ?? footer.hitOver,
          infiniteHitOver: infiniteHitOver ?? footer.infiniteHitOver,
          position: position ?? footer.position,
          hapticFeedback: hapticFeedback ?? footer.hapticFeedback,
          secondaryTriggerOffset:
              secondaryTriggerOffset ?? footer.secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity ?? footer.secondaryVelocity,
          secondaryDimension: secondaryDimension ?? footer.secondaryDimension,
          secondaryCloseTriggerOffset:
              secondaryCloseTriggerOffset ?? footer.secondaryCloseTriggerOffset,
          notifyWhenInvisible:
              notifyWhenInvisible ?? footer.notifyWhenInvisible,
          listenable: listenable ?? footer.listenable,
          triggerWhenReach: triggerWhenReach ?? footer.triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease ?? footer.triggerWhenRelease,
          triggerWhenReleaseNoWait:
              triggerWhenReleaseNoWait ?? footer.triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset ?? footer.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return footer.build(context, state);
  }
}
