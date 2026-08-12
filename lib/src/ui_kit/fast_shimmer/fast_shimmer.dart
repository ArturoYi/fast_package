import 'package:flutter/material.dart';

import 'fast_shimmer_scope.dart';

/// Switches between an explicit [skeleton] and real [child] content.
/// 在显式 [skeleton] 与真实 [child] 内容之间切换。
///
/// This is the primary entry widget for loading placeholders. It **only**
/// supports hand-crafted skeletons — there is **no** auto shape detection
/// from the [child] widget tree.
/// 这是加载占位的主入口组件。它**只**支持手写骨架——**不会**根据 [child]
/// 组件树自动推断形状。
///
/// While [isLoading] is `true`, [skeleton] is shown inside a [FastShimmerScope]
/// (auto-wrapped when no ancestor scope exists) with loading semantics.
/// 当 [isLoading] 为 `true` 时，展示 [skeleton]，并在无祖先 Scope 时自动包一层
/// [FastShimmerScope]，同时带上加载态语义。
///
/// ```dart
/// FastShimmer(
///   isLoading: _loading,
///   skeleton: Column(
///     children: [
///       FastShimmerBox(width: double.infinity, height: 180),
///       SizedBox(height: 12),
///       Row(
///         children: [
///           FastShimmerCircle(diameter: 48),
///           SizedBox(width: 12),
///           FastShimmerText(lines: 2, width: 160),
///         ],
///       ),
///     ],
///   ),
///   child: MyRealContent(),
/// )
/// ```
///
/// Skeleton children should be opaque (typically white via package
/// placeholders) so the [ShaderMask] gradient is visible.
/// 骨架子节点应为不透明（包内占位组件默认白底），以便 [ShaderMask] 渐变可见。
class FastShimmer extends StatelessWidget {
  /// Creates a loading switch between [skeleton] and [child].
  /// 创建在 [skeleton] 与 [child] 之间切换的加载组件。
  ///
  /// [skeleton] is **required**. Auto-detecting shapes from [child] is
  /// intentionally unsupported.
  /// [skeleton] 为**必填**。故意不支持从 [child] 自动检测形状。
  const FastShimmer({
    super.key,
    required this.child,
    required this.isLoading,
    required this.skeleton,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// The real content shown when [isLoading] is `false`.
  /// 当 [isLoading] 为 `false` 时展示的真实内容。
  final Widget child;

  /// When `true`, shows [skeleton]; when `false`, shows [child].
  /// 为 `true` 时展示 [skeleton]；为 `false` 时展示 [child]。
  final bool isLoading;

  /// Explicit hand-crafted skeleton layout shown while loading.
  /// 加载中展示的显式手写骨架布局。
  ///
  /// Prefer composing [FastShimmerBox], [FastShimmerCircle],
  /// [FastShimmerText], and [FastShimmerList].
  /// 推荐组合使用 [FastShimmerBox]、[FastShimmerCircle]、
  /// [FastShimmerText] 与 [FastShimmerList]。
  final Widget skeleton;

  /// Duration of one shimmer cycle when this widget auto-creates a
  /// [FastShimmerScope]. Ignored if an ancestor scope already exists.
  /// 当本组件自动创建 [FastShimmerScope] 时使用的单次扫光时长。
  /// 若已有祖先 Scope，则忽略该参数。
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    // Announce loading and hide phantom text from screen readers.
    // 向读屏软件宣告加载态，并排除骨架内的杂散语义。
    final Widget loadingSkeleton = Semantics(
      label: 'Loading',
      excludeSemantics: true,
      child: skeleton,
    );

    // Avoid double ShaderMask when already under a scope.
    // 已在 Scope 下时避免再包一层导致双重遮罩。
    if (FastShimmerScope.hasScope(context)) {
      return loadingSkeleton;
    }

    return FastShimmerScope(
      duration: duration,
      child: loadingSkeleton,
    );
  }
}
