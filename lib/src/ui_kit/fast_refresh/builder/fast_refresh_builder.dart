part of '../fast_refresh.dart';

/// [FastRefresh.builder] 的子节点构建器。
///
/// 入参 [physics] 是 FastRefresh 的越界物理，必须挂到**真正要刷新 / 加载**
/// 的那一个 [ScrollView] 上。与默认构造不同：这份 physics **不会**再通过
/// [ScrollConfiguration] 注入子树。
///
/// 对齐 EasyRefresh 的 `ERChildBuilder`。
///
/// ## Widget 构造 vs builder
///
/// **[FastRefresh]（Widget 构造）** 把 physics 注入整个 [child] 作用域，
/// [ListView] 不用写 `physics`。写起来最短，但子树里多个 [ScrollView]
/// 会共用同一份物理，嵌套滚动容易抢越界。
///
/// **[FastRefresh.builder]** 不注入作用域，必须在回调里显式挂上：
///
/// ```dart
/// FastRefresh.builder(
///   onRefresh: () async {},
///   childBuilder: (context, physics) {
///     return CustomScrollView(
///       physics: physics,
///       slivers: const [
///         SliverAppBar(pinned: true, title: Text('标题')),
///         SliverList(delegate: SliverChildListDelegate.fixed([])),
///       ],
///     );
///   },
/// );
/// ```
///
/// | | Widget 构造 | builder |
/// | --- | --- | --- |
/// | physics 怎么到列表 | [ScrollConfiguration] 自动注入 | 调用方挂到 [ScrollView.physics] |
/// | 子树多个 ScrollView | 共用同一份，容易抢手势 | 只挂你指定的那一层 |
/// | 嵌套滚动 | 不推荐 | 推荐，可配合 [FastRefresh.isNested] |
/// | 代码量 | 少 | 多写一个 `physics` 参数 |
///
/// 拿不准先用 Widget 构造；出现「里层列表把刷新抢走」再换成 builder。
/// 漏写 `physics: physics` 时，列表仍用平台默认物理，下拉不会进入刷新状态机。
typedef FastRefreshChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics);

/// 自定义 [ScrollBehavior] 工厂。参数是将要注入的 physics，可为 `null`。
///
/// [FastRefresh] 默认构造会传入 [_FRScrollPhysics]；
/// [FastRefresh.builder] 传入 `null`，由 [FastRefreshChildBuilder] 自己挂物理。
typedef FastRefreshScrollBehaviorBuilder = ScrollBehavior Function(
    ScrollPhysics? physics);
