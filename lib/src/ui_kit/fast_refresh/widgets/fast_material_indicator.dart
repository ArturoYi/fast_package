part of '../fast_refresh.dart';

/// Material 风格 Header：列表不越界，用 [RefreshProgressIndicator] 跟手。
class FastMaterialHeader extends FastRefreshHeader {
  /// 指示器颜色。未传时走 [FastRefreshTheme.indicatorColor] 或 [ColorScheme.primary]。
  final Color? color;

  /// 指示器背景色。
  final Color? backgroundColor;

  /// 创建 Material Header。默认 [clamping] 为 true、[processedDuration] 为零。
  const FastMaterialHeader({
    super.triggerOffset = 70,
    super.clamping = true,
    super.position,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return _FastMaterialIndicator(
      state: state,
      color: color,
      backgroundColor: backgroundColor,
      useRefreshIndicator: true,
    );
  }
}

/// Material 风格 Footer：转圈，默认触底加载（[infiniteOffset] 为 70）。
///
/// [clamping] 默认为 false，才能与触底加载同时使用。
class FastMaterialFooter extends FastRefreshFooter {
  /// 指示器颜色。未传时走 [FastRefreshTheme.indicatorColor] 或 [ColorScheme.primary]。
  final Color? color;

  /// 指示器背景色。
  final Color? backgroundColor;

  /// 创建 Material Footer。
  const FastMaterialFooter({
    super.triggerOffset = 70,
    super.clamping = false,
    super.position,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.safeArea,
    super.infiniteOffset = 70,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return _FastMaterialIndicator(
      state: state,
      color: color,
      backgroundColor: backgroundColor,
      useRefreshIndicator: false,
    );
  }
}

class _FastMaterialIndicator extends StatelessWidget {
  const _FastMaterialIndicator({
    required this.state,
    required this.useRefreshIndicator,
    this.color,
    this.backgroundColor,
  });

  final FastRefreshIndicatorState state;
  final bool useRefreshIndicator;
  final Color? color;
  final Color? backgroundColor;

  bool get _indeterminate {
    return state.mode == FastRefreshMode.ready ||
        state.mode == FastRefreshMode.processing;
  }

  double? get _progress {
    if (_indeterminate) {
      return null;
    }
    final double trigger = state.actualTriggerOffset;
    if (trigger <= 0) {
      return 0;
    }
    return (state.offset / trigger).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final FastRefreshTheme theme = FastRefreshTheme.resolve(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color indicatorColor =
        color ?? theme.indicatorColor ?? scheme.primary;
    final Color? indicatorBackground =
        backgroundColor ?? theme.backgroundColor;
    final double size = theme.progressIndicatorSize ?? 24;
    final double strokeWidth = theme.progressIndicatorStrokeWidth ?? 2.5;
    final bool vertical = state.axis == Axis.vertical;
    if (state.offset <= 0) {
      return const SizedBox.shrink();
    }
    final Widget indicator = useRefreshIndicator
        ? RefreshProgressIndicator(
            value: _progress,
            color: indicatorColor,
            backgroundColor: indicatorBackground,
            strokeWidth: strokeWidth,
          )
        : SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: _progress,
              color: indicatorColor,
              backgroundColor: indicatorBackground,
              strokeWidth: strokeWidth,
            ),
          );
    return SizedBox(
      width: vertical ? double.infinity : state.offset,
      height: vertical ? state.offset : double.infinity,
      child: Center(child: indicator),
    );
  }
}
