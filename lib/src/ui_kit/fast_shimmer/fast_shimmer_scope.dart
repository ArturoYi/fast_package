import 'package:flutter/material.dart';

import 'fast_shimmer_theme.dart';

/// Provides a single shared [AnimationController] to all descendant shimmer
/// placeholders and applies an animated gradient via [ShaderMask].
/// 为所有后代 shimmer 占位提供**同一个**共享 [AnimationController]，
/// 并通过 [ShaderMask] 套上动画渐变。
///
/// Place [FastShimmerScope] around an explicit skeleton built from
/// [FastShimmerBox], [FastShimmerCircle], [FastShimmerText], [FastShimmerList],
/// or any opaque (typically white) containers:
/// 用 [FastShimmerScope] 包裹由 [FastShimmerBox]、[FastShimmerCircle]、
/// [FastShimmerText]、[FastShimmerList] 或任意不透明（通常为白色）容器
/// 组成的显式骨架：
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
  /// [duration] is the length of one full highlight cycle. Defaults to
  /// 1500 ms. Prefer matching [FastShimmerTheme.duration] for app-wide feel.
  /// [duration] 为一次完整扫光循环的时长，默认 1500 ms。
  /// 若希望与全局主题一致，可对齐 [FastShimmerTheme.duration]。
  const FastShimmerScope({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// The skeleton subtree that receives the shimmer [ShaderMask].
  /// 接收 shimmer [ShaderMask] 的骨架子树。
  final Widget child;

  /// Duration of one complete shimmer cycle.
  /// 一次完整 shimmer 循环的时长。
  final Duration duration;

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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimationWithAccessibility();
  }

  @override
  void didUpdateWidget(FastShimmerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
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
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
        final double value = _controller.value;

        // Three-stop gradient: base → highlight → base, shifted by [value].
        // 三段渐变：底色 → 高光 → 底色，随 [value] 平移。
        final LinearGradient gradient = theme.direction.toGradient(
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

        return _FastShimmerScopeInherited(
          value: value,
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              return gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              );
            },
            child: child!,
          ),
        );
      },
    );
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
