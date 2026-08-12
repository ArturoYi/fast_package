import 'package:flutter/material.dart';

import 'fast_shimmer_circle.dart';
import 'fast_shimmer_text.dart';

/// Renders [itemCount] repeating shimmer row placeholders.
/// 渲染 [itemCount] 个重复的 shimmer 行占位。
///
/// Wrap with [FastShimmerScope] so every row shares one highlight animation.
/// Without a scope, rows still render as visible static placeholders (each
/// child resolves its own fill color).
/// 请用 [FastShimmerScope] 包裹，使每一行共享同一次扫光动画。
/// 若没有 Scope，各行仍会以静态占位形式可见（子组件自行解析填充色）。
///
/// Provide a custom [itemBuilder], or omit it to use the built-in default row
/// (circle avatar + two text lines).
/// 可传入自定义 [itemBuilder]；省略时使用内置默认行
/// （圆形头像 + 两行文字）。
///
/// ```dart
/// FastShimmerScope(
///   child: FastShimmerList(
///     itemCount: 5,
///     itemBuilder: (index) => Padding(
///       padding: EdgeInsets.symmetric(vertical: 8),
///       child: Row(
///         children: [
///           FastShimmerCircle(diameter: 40),
///           SizedBox(width: 12),
///           FastShimmerText(lines: 2, width: 160),
///         ],
///       ),
///     ),
///   ),
/// )
/// ```
class FastShimmerList extends StatelessWidget {
  /// Creates a repeating list of shimmer placeholders.
  /// 创建重复的 shimmer 列表占位。
  ///
  /// [itemCount] must be non-negative.
  /// [itemCount] 必须为非负数。
  ///
  /// When [itemBuilder] is `null`, a default list-tile style skeleton is used.
  /// 当 [itemBuilder] 为 `null` 时，使用默认的列表项风格骨架。
  const FastShimmerList({
    super.key,
    required this.itemCount,
    this.itemBuilder,
    this.separatorHeight = 12.0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  /// Number of placeholder rows to build.
  /// 要构建的占位行数量。
  final int itemCount;

  /// Builds the skeleton for each index. Defaults to [_defaultItem].
  /// 按索引构建骨架；默认使用 [_defaultItem]。
  final Widget Function(int index)? itemBuilder;

  /// Vertical gap between rows (via [ListView.separated]).
  /// 行与行之间的垂直间距（通过 [ListView.separated]）。
  final double separatorHeight;

  /// Padding around the list.
  /// 列表外边距。
  final EdgeInsetsGeometry padding;

  /// Whether the list should shrink-wrap its contents.
  /// 列表是否按内容收缩高度。
  final bool shrinkWrap;

  /// Scroll physics. Defaults to non-scrollable for embedding in parents.
  /// 滚动物理效果。默认不可滚动，便于嵌入父级滚动视图。
  final ScrollPhysics? physics;

  /// Default list-tile style skeleton: leading circle + two text lines.
  /// 默认列表项骨架：左侧圆形 + 两行文字。
  static Widget _defaultItem(int index) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FastShimmerCircle(diameter: 40),
        SizedBox(width: 12),
        FastShimmerText(lines: 2, width: 180),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(itemCount >= 0, 'itemCount must be non-negative');

    final Widget Function(int index) builder = itemBuilder ?? _defaultItem;

    return Padding(
      padding: padding,
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: separatorHeight);
        },
        itemBuilder: (BuildContext context, int index) => builder(index),
      ),
    );
  }
}
