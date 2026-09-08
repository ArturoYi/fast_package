---
title: Refresh 刷新加载
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_refresh" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_refresh/</code>
</p>

## 概览 {#overview}

`FastRefresh` 对齐 EasyRefresh 的核心物理与状态机：自定义 `ScrollPhysics` 处理摩擦 / 回弹 / 越界，Header/Footer notifier 驱动

`inactive → drag → armed → ready → processing → processed → done`，

松手后先吸到触发位再执行任务。默认皮肤是 Classic（箭头旋转 + 文案 + 转圈）。

| 要点 | 说明 |
| --- | --- |
| 主入口 | `FastRefresh(onRefresh, onLoad, child)`，也可用 `FastRefresh.builder` |
| 控制器 | `FastRefreshController`：`callRefresh` / `callLoad` / `finish*` / `resetFooter` |
| 结果 | `success` / `fail` / `noMore` |
| 默认指示器 | `FastClassicHeader` / `FastClassicFooter` |
| 自定义 | `FastBuilderHeader` / `FastBuilderFooter`，或 `FastListenerHeader` / `Locator` |
| 物理 | bouncing（列表跟着走）与 clamping（列表不动、指示器动） |

::: tip
`child` 里不要再嵌套另一套独立滚动（除非给里层单独设 `physics`，或改用 `FastRefresh.builder` 自己挂 physics）。完整演示见 example 的 `RefreshExample` 页。
:::

---

## 基础用法 {#basic}

```dart
import 'package:fast_package/fast_package.dart';

final controller = FastRefreshController(
  controlFinishRefresh: true,
  controlFinishLoad: true,
);

FastRefresh(
  controller: controller,
  header: const FastClassicHeader(
    dragText: '下拉刷新',
    armedText: '释放刷新',
    processingText: '正在刷新...',
  ),
  footer: const FastClassicFooter(
    dragText: '上拉加载',
    processingText: '正在加载...',
    noMoreText: '没有更多了',
  ),
  onRefresh: () async {
    await fetchFirstPage();
    controller.finishRefresh();
    controller.resetFooter();
  },
  onLoad: () async {
    final hasMore = await fetchNextPage();
    controller.finishLoad(
      hasMore ? FastRefreshResult.success : FastRefreshResult.noMore,
    );
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => ListTile(title: Text(items[i])),
  ),
);
```

`onRefresh` / `onLoad` 为 `null` 时，对应能力关闭。

也可以不接管完成事件，直接 `return FastRefreshResult.success`（或 `fail` / `noMore`）。回调抛错视为 `fail`，不会把异常抛到框架外。

---

## Widget 构造 vs builder {#widget-vs-builder}

对齐 EasyRefresh：默认构造把 physics 注入作用域；`FastRefresh.builder` 把 physics 交给你。

### Widget 构造 {#widget-ctor}

```dart
FastRefresh(
  onRefresh: () async {},
  child: ListView(), // 不必写 physics
);
```

| | 说明 |
| --- | --- |
| 优点 | 单列表零样板，子 [ScrollView] 自动用刷新物理 |
| 缺点 | 子树里多个滚动视图会共用同一份物理，嵌套时容易抢越界 |
| 适用 | 一个 `ListView` / `GridView` / `CustomScrollView` |

### builder 构造 {#builder-ctor}

```dart
FastRefresh.builder(
  onRefresh: () async {},
  childBuilder: (context, physics) {
    return CustomScrollView(
      physics: physics, // 必须挂上，否则下拉不会刷新
      slivers: [
        const SliverAppBar(pinned: true, title: Text('标题')),
        SliverList(delegate: SliverChildListDelegate.fixed([])),
      ],
    );
  },
);
```

| | 说明 |
| --- | --- |
| 优点 | 精确指定哪一层参与刷新；嵌套 / 多列表不会误伤 |
| 缺点 | 漏写 `physics: physics` 时列表仍是平台默认物理，刷新不会触发 |
| 适用 | `NestedScrollView`、`PageView` 套列表、外层还有独立滚动 |

拿不准先用 Widget 构造；出现「里层列表把刷新抢走」再换成 builder。可配合 `isNested: true`。example 里 `refresh_example/widget` 与 `refresh_example/builder` 对照。

---

## 状态机 {#states}

```
inactive → drag → armed → ready → processing → processed → done → inactive
```

| 模式 | 含义 |
| --- | --- |
| `inactive` | 隐藏 |
| `drag` | 已越界，未到触发距离 |
| `armed` | 已过阈值，松手即触发 |
| `ready` | 已松手，弹簧吸到触发位 |
| `processing` | 正在跑回调 |
| `processed` | 任务结束，展示完成态 |
| `done` | 完成态结束，等待回弹 |

Footer 默认 `infiniteOffset = 70`：距底部小于 70 即自动加载，不必先越界再松手。传入 `infiniteOffset: null` 可改回「拉过阈值再松手」。

刷新成功且 `resetAfterRefresh` 为 true（默认）时，会清掉 Footer 的 `noMore`。

默认刷新与加载互斥；需要同时进行时设 `simultaneously: true`。

---

## 更多能力 {#more}

- **`FastRefresh.builder`**：见 [Widget 构造 vs builder](#widget-vs-builder)。
- **`refreshOnStart`**：首帧构建完成后自动触发刷新。
- **`FastHeaderLocator` / `FastFooterLocator`**：把指示器放进列表内部（`position: locator`）。
- **`clamping: true`**：列表不跟着越界，只有指示器移动（Material 风格）。
- **二楼**：`secondaryTriggerOffset` + `openHeaderSecondary` / `closeHeaderSecondary`。

---

## 自定义指示器 {#custom}

```dart
FastRefresh(
  header: FastBuilderHeader(
    triggerOffset: 70,
    processedDuration: Duration.zero,
    builder: (context, state) {
      return SizedBox(
        height: state.offset,
        child: Center(child: Text(state.mode.name)),
      );
    },
  ),
  onRefresh: () async {},
  child: ListView(),
);
```

可用 `FastRefreshStateListenable` 在指示器外监听快照。
