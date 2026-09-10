import 'package:flutter/material.dart';

import 'fast_shimmer_theme.dart';

/// How the highlight travels across a [FastShimmerScope].
/// [FastShimmerScope] 高光扫过子树的方式。
enum FastShimmerSweep {
  /// Wide three-stop wash used by loading skeletons.
  /// 加载骨架用的宽幅三段渐变。
  wash,

  /// Soft slanted sheen, like a light beam on metal.
  /// 斜向柔边高光，类似光束扫过金属表面。
  beam,
}

/// Provides a single shared [AnimationController] to all descendant shimmer
/// placeholders and applies an animated gradient via [ShaderMask].
/// 为所有后代 shimmer 占位提供**同一个**共享 [AnimationController]，
/// 并通过 [ShaderMask] 套上动画渐变。
///
/// Place [FastShimmerScope] around an explicit skeleton built from
/// [FastShimmerBox], [FastShimmerCircle], [FastShimmerText], [FastShimmerList],
/// or any opaque child — including [Text] / [Icon] (solid color) for
/// decorative highlight effects such as [FastShimmerHighlight]:
/// 用 [FastShimmerScope] 包裹由 [FastShimmerBox]、[FastShimmerCircle]、
/// [FastShimmerText]、[FastShimmerList] 拼成的骨架，或任意不透明子节点
/// （含实心 [Text] / [Icon]，见 [FastShimmerHighlight]）：
///
/// ```dart
/// FastShimmerScope(
///   child: Column(
///     children: [
///       FastShimmerBox(width: double.infinity, height: 180),
///       SizedBox(height: 12),
///       FastShimmerCircle(diameter: 48),
///       FastShimmerText(lines: 2, width: 160),
///     ],
///   ),
/// )
/// ```
///
/// Because the gradient is applied once at this level, every child stays in
/// phase. [AnimatedBuilder] caches [child], so placeholders do not rebuild on
/// each animation tick.
/// 渐变只在 Scope 这一层应用一次，因此所有子节点相位同步。
/// [AnimatedBuilder] 会缓存 [child]，占位组件不会因动画帧而重建。
///
/// When [MediaQueryData.disableAnimations] is `true`, the controller stops and
/// freezes at mid-cycle (`0.5`) so the skeleton stays visible but stationary.
/// 当 [MediaQueryData.disableAnimations] 为 `true` 时，控制器停止并定格在
/// 循环中点（`0.5`），骨架仍可见但不移动。
///
/// Prefer one scope per screen/subtree. Nested scopes are allowed but usually
/// unnecessary; use [hasScope] to avoid auto double-wrapping.
/// 建议每个页面/子树只放一个 Scope。允许嵌套但通常不必要；
/// 可用 [hasScope] 避免自动双重包裹。
class FastShimmerScope extends StatefulWidget {
  /// Creates a shimmer scope that drives synchronized highlight animation.
  /// 创建一个驱动同步扫光动画的 shimmer 作用域。
  ///
  /// [child] is the skeleton subtree that should shimmer.
  /// [child] 是需要呈现 shimmer 效果的骨架子树。
  ///
  /// [duration] is the length of the **sweep** (left → right, etc.).
  /// Defaults to 1500 ms. After the sweep, [pauseDuration] holds before
  /// the next loop. Prefer matching [FastShimmerTheme.duration] for
  /// skeleton feel.
  /// [duration] 是**扫过**的时长（左 → 右等），默认 1500 ms。
  /// 扫完后按 [pauseDuration] 停顿再循环。骨架手感可对齐
  /// [FastShimmerTheme.duration]。
  const FastShimmerScope({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.pauseDuration = Duration.zero,
    this.sweep = FastShimmerSweep.wash,
    this.bandWidth = 0.18,
    this.sheenRotation = beamSheenRotation,
  });

  /// The skeleton subtree that receives the shimmer [ShaderMask].
  /// 接收 shimmer [ShaderMask] 的骨架子树。
  final Widget child;

  /// Duration of the highlight sweep, not including [pauseDuration].
  /// 高光扫过的时长，不含 [pauseDuration]。
  final Duration duration;

  /// Hold after the sweep finishes, before the next loop.
  /// 扫完后、下一轮开始前的停顿。
  ///
  /// Defaults to [Duration.zero] so loading skeletons stay a continuous wash.
  /// 默认 [Duration.zero]，加载骨架保持连续扫光。
  final Duration pauseDuration;

  /// Wash (skeletons) vs thin traveling beam (decorative highlight).
  /// 骨架用的宽幅洗刷，或装饰扫光用的细光束。
  final FastShimmerSweep sweep;

  /// Beam width as a fraction of the sweep-axis length. Used by
  /// [FastShimmerSweep.beam] only. Wider values look softer.
  /// 高光带相对扫光轴长度的比例，仅 [FastShimmerSweep.beam] 使用。
  /// 越大羽化越软。
  final double bandWidth;

  /// Slight tilt so a beam reads as metal sheen, not a hard vertical wipe.
  /// 略微倾斜，让光束像金属高光而不是硬直条。
  static const double beamSheenRotation = -0.45;

  /// Radians applied to a [FastShimmerSweep.beam] gradient. `0` is a
  /// straight left-to-right swipe (better on short text).
  /// [FastShimmerSweep.beam] 渐变的倾斜角（弧度）。`0` 为水平扫过
  /// （短文字上更清楚）。
  final double sheenRotation;

  /// Returns the current animation value (`0.0`–`1.0`) from the nearest
  /// [FastShimmerScope], or `0.5` when no scope is present.
  /// 返回最近 [FastShimmerScope] 的当前动画值（`0.0`–`1.0`）；
  /// 若没有 Scope 则返回 `0.5`。
  ///
  /// Subscribes to inherited updates (rebuilds when the value changes).
  /// 会订阅 Inherited 更新（动画值变化时触发重建）。
  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_FastShimmerScopeInherited>()
            ?.value ??
        0.5;
  }

  /// Returns the animation value if a [FastShimmerScope] ancestor exists,
  /// otherwise `null`.
  /// 若存在祖先 [FastShimmerScope] 则返回动画值，否则返回 `null`。
  ///
  /// Subscribes to inherited updates when a scope is found.
  /// 找到 Scope 时会订阅 Inherited 更新。
  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_FastShimmerScopeInherited>()
        ?.value;
  }

  /// Returns whether a [FastShimmerScope] ancestor exists **without**
  /// subscribing to per-frame updates.
  /// 返回是否存在祖先 [FastShimmerScope]，**不会**订阅每帧更新。
  ///
  /// Use this when deciding whether to auto-wrap with another scope.
  /// 用于判断是否还需要再自动包一层 Scope。
  static bool hasScope(BuildContext context) {
    return context.getElementForInheritedWidgetOfExactType<
            _FastShimmerScopeInherited>() !=
        null;
  }

  @override
  State<FastShimmerScope> createState() => _FastShimmerScopeState();
}

class _FastShimmerScopeState extends State<FastShimmerScope>
    with SingleTickerProviderStateMixin {
  /// Shared controller that drives all descendant shimmer highlights.
  /// 驱动所有后代 shimmer 高光的共享控制器。
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Start repeating immediately; reduce-motion handling runs in
    // didChangeDependencies once MediaQuery is available.
    // 立即开始循环；减少动画的处理在 MediaQuery 可用后的
    // didChangeDependencies 中进行。
    _controller = AnimationController(vsync: this, duration: _cycleDuration)
      ..repeat();
  }

  /// Sweep + pause. Controller `0`–`1` maps across this whole period.
  /// 扫过 + 停顿。控制器的 `0`–`1` 对应这整段周期。
  Duration get _cycleDuration {
    final int total = widget.duration.inMicroseconds +
        widget.pauseDuration.inMicroseconds;
    return Duration(microseconds: total > 0 ? total : 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimationWithAccessibility();
  }

  @override
  void didUpdateWidget(FastShimmerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.pauseDuration != widget.pauseDuration) {
      _controller.duration = _cycleDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stops and freezes at mid-cycle when reduce-motion is on; otherwise
  /// ensures the controller keeps repeating.
  /// 开启「减少动态效果」时停止并定格在中点；否则确保控制器持续循环。
  void _syncAnimationWithAccessibility() {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      _controller
        ..stop()
        ..value = _controllerValueForSweep(0.5);
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  /// Maps a sweep progress (`0`–`1`) onto the controller, accounting for pause.
  /// 把扫光进度（`0`–`1`）映射到控制器，并计入停顿段。
  double _controllerValueForSweep(double sweepT) {
    final int sweep = widget.duration.inMicroseconds;
    final int pause = widget.pauseDuration.inMicroseconds;
    if (pause <= 0 || sweep <= 0) {
      return sweepT;
    }
    return sweepT * sweep / (sweep + pause);
  }

  /// Beam / wash position (`0`–`1`). Stays at `1` during [pauseDuration].
  /// 光束 / 洗刷位置（`0`–`1`）。在 [pauseDuration] 期间停在 `1`。
  double _sweepProgress(double controllerValue) {
    final int sweep = widget.duration.inMicroseconds;
    final int pause = widget.pauseDuration.inMicroseconds;
    if (pause <= 0 || sweep <= 0) {
      return controllerValue;
    }
    final double sweepEnd = sweep / (sweep + pause);
    if (controllerValue >= sweepEnd) {
      return 1.0;
    }
    return controllerValue / sweepEnd;
  }

  @override
  Widget build(BuildContext context) {
    // Colors / direction come from theme; duration stays on the widget.
    // 颜色与方向来自主题；时长仍由组件参数控制。
    final FastShimmerTheme theme = FastShimmerTheme.resolve(context);

    return AnimatedBuilder(
      animation: _controller,
      // Cache the skeleton tree so animation ticks do not rebuild it.
      // 缓存骨架树，避免动画帧触发子树重建。
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double value = _sweepProgress(_controller.value);

        final LinearGradient gradient = widget.sweep == FastShimmerSweep.beam
            ? _beamGradient(theme, value)
            : _washGradient(theme, value);

        return _FastShimmerScopeInherited(
          value: value,
          child: ShaderMask(
            // srcIn: dest is only a mask. srcATop + translucent shader colors
            // over white glyphs collapses back to white and hides the beam.
            // srcIn：目标只当遮罩。srcATop 加半透明着色叠在白色字形上
            // 会混回纯白，文字扫光看起来像没动。
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) {
              return gradient.createShader(bounds);
            },
            child: child!,
          ),
        );
      },
    );
  }

  /// Legacy skeleton wash: wide base → highlight → base, stops follow [value].
  /// 骨架用的宽幅洗刷：底色 → 高光 → 底色，stops 跟随 [value]。
  LinearGradient _washGradient(FastShimmerTheme theme, double value) {
    return theme.direction.toGradient(
      colors: <Color>[
        theme.baseColor,
        theme.highlightColor,
        theme.baseColor,
      ],
      stops: <double>[
        (value - 0.3).clamp(0.0, 1.0),
        value.clamp(0.0, 1.0),
        (value + 0.3).clamp(0.0, 1.0),
      ],
    );
  }

  /// Slanted soft sheen. Peak travels from just off-start to just off-end
  /// so the pause at `1.0` leaves only [FastShimmerTheme.baseColor].
  /// 斜向柔光。峰值从起点外侧走到终点外侧，停在 `1.0` 时只剩底色。
  LinearGradient _beamGradient(FastShimmerTheme theme, double value) {
    final double half = widget.bandWidth.clamp(0.08, 0.55);
    final double peak = -half + (1.0 + 2 * half) * value;
    final Color mid = Color.lerp(theme.baseColor, theme.highlightColor, 0.28)!;

    return LinearGradient(
      begin: theme.direction.begin,
      end: theme.direction.end,
      colors: <Color>[
        theme.baseColor,
        mid,
        theme.highlightColor,
        mid,
        theme.baseColor,
      ],
      stops: _beamStops(peak, half),
      transform: widget.sheenRotation == 0
          ? null
          : GradientRotation(widget.sheenRotation),
    );
  }

  /// Five stops around [peak], clamped and non-decreasing in `0`–`1`.
  /// 以 [peak] 为中心的五个 stop，钳制在 `0`–`1` 且单调不减。
  List<double> _beamStops(double peak, double half) {
    final List<double> stops = <double>[
      (peak - half).clamp(0.0, 1.0),
      (peak - half * 0.38).clamp(0.0, 1.0),
      peak.clamp(0.0, 1.0),
      (peak + half * 0.38).clamp(0.0, 1.0),
      (peak + half).clamp(0.0, 1.0),
    ];
    for (int i = 1; i < stops.length; i++) {
      if (stops[i] < stops[i - 1]) {
        stops[i] = stops[i - 1];
      }
    }
    return stops;
  }
}

/// Inherited host that exposes the current shimmer animation value.
/// 向下暴露当前 shimmer 动画值的 Inherited 宿主。
class _FastShimmerScopeInherited extends InheritedWidget {
  const _FastShimmerScopeInherited({
    required this.value,
    required super.child,
  });

  /// Current animation value in the range `0.0`–`1.0`.
  /// 当前动画值，范围 `0.0`–`1.0`。
  final double value;

  @override
  bool updateShouldNotify(_FastShimmerScopeInherited oldWidget) {
    return oldWidget.value != value;
  }
}
