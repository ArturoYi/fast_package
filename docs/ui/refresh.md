---
title: Refresh 刷新加载
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_refresh" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_refresh/</code>
</p>

<DocCredit module="refresh" />

## 概览 {#overview}

`FastRefresh` 用自定义 `ScrollPhysics` 处理摩擦 / 回弹 / 越界，Header/Footer notifier 驱动

`inactive → drag → armed → ready → processing → processed → done`，

松手后先吸到触发位再执行任务。默认皮肤是 Classic（箭头旋转 + 文案 + 转圈）。

| 要点 | 说明 |
| --- | --- |
| 主入口 | `FastRefresh(onRefresh, onLoad, child)`，也可用 `FastRefresh.builder` |
| 控制器 | `FastRefreshController`：`callRefresh` / `callLoad` / `finish*` / `resetFooter` |
| 结果 | `success` / `fail` / `noMore` |
| 分页 | `FastPagingList`（`fetchPage`）或继承 `FastPaging` |
| 默认指示器 | `FastClassicHeader` / `FastClassicFooter`；可选 `FastMaterial*` |
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

## Widget vs builder {#widget-vs-builder}

默认构造把 physics 注入作用域；`FastRefresh.builder` 把 physics 交给你。

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
Scaffold(
  appBar: AppBar(title: const Text('标题')),
  body: FastRefresh.builder(
    onRefresh: () async {},
    childBuilder: (context, physics) {
      return CustomScrollView(
        physics: physics, // 必须挂上，否则下拉不会刷新
        slivers: [
          SliverList(delegate: SliverChildListDelegate.fixed([])),
        ],
      );
    },
  ),
);
```

AppBar 放在 `FastRefresh` 外面，刷新从列表顶开始。不要把 `SliverAppBar` 塞进默认 builder；折叠顶栏用 Nested（`isNested: true`）或 Locator。

| | 说明 |
| --- | --- |
| 优点 | 精确指定哪一层参与刷新；嵌套 / 多列表不会误伤 |
| 缺点 | 漏写 `physics: physics` 时列表仍是平台默认物理，刷新不会触发 |
| 适用 | `NestedScrollView`、`PageView` 套列表、外层还有独立滚动 |

拿不准先用 Widget 构造；出现「里层列表把刷新抢走」再换成 builder。可配合 `isNested: true`。example 入口有 Widget、Builder、Nested、Locator、refreshOnStart、Paging、clamping、横向、二楼。

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

刷新**成功**且 `resetAfterRefresh` 为 true（默认）时，会清掉 Footer 的 `noMore`。失败、抛错或 `noMore` 不会清。接管完成时，改到 `finishRefresh(success)` 才 reset。

`FastRefresh` 销毁或更换 controller 后，旧控制器上的 `callRefresh` / `finishRefresh` 为空操作。

默认刷新与加载互斥；需要同时进行时设 `simultaneously: true`。

---

## 更多能力 {#more}

与 example 入口同一顺序：

- **`FastRefresh.builder`**：见 [Widget 构造 vs builder](#widget-vs-builder)。example 的 `refresh_example/builder`。
- **`isNested: true`**：`NestedScrollView` 外层钉顶栏、内层列表刷新。example 的 `refresh_example/nested`。
- **`FastHeaderLocator` / `FastFooterLocator`**：把指示器放进列表内部（`position: locator`）。example 的 `refresh_example/locator`。
- **`refreshOnStart`**：首帧构建完成后自动触发刷新。example 的 `refresh_example/refresh_on_start`。
- **`FastPaging` / `FastPagingList`**：页码 / 总数 / 空态接到刷新与加载。`FastPagingList` 只需 `fetchPage` + `itemBuilder`。example 的 `refresh_example/paging`。见 [分页](#paging)。
- **上拉加载与滚动**：新数据 push 时不打断惯性。见 [上拉加载与滚动](#load-more)。
- **`clamping: true`**：列表不跟着越界，只有指示器移动。example 的 `refresh_example/clamping`。
- **`FastMaterialHeader` / `FastMaterialFooter`**：系统月牙转圈。example 的 `refresh_example/material`。见 [Material](#material)。
- **`FastRefreshTheme`**：Classic 文案与 Material 颜色走 `ThemeExtension`。见 [Theme](#theme)。
- **横向**：`ListView` / `PageView` 的 `scrollDirection` 为 horizontal。example 的 `refresh_example/horizontal`。见 [横向](#horizontal)。
- **二楼**：继续下拉打开第二页。example 的 `refresh_example/secondary`。见 [二楼](#secondary)。

---

## 分页 {#paging}

日常列表用 `FastPagingList<T>`，不必写子类：

```dart
FastPagingList<String>(
  refreshOnStart: true,
  fetchPage: (page) async {
    final res = await api.list(page);
    return FastPagingPage(
      items: res.items,
      page: res.page,
      total: res.total,
    );
  },
  itemBuilder: (context, index, item) => ListTile(title: Text(item)),
)
```

`isNoMore`：显式 `hasMore` → `total` / `page`+`totalPage` → 最近一次成功页的 `items` 为空。复杂 data 仍用 `FastPaging` 子类。

`FastPaging<DataType, ItemType>` 对齐 EasyRefresh 配套的 `EasyPaging`：子类只维护数据和页码，刷新 / 加载生命周期、空态、`noMore` 由基类接到 `FastRefresh`。

`isNoMore` 优先看 `total`（`count >= total`），否则看 `page >= totalPage`。`onLoad` 不返回结果时，基类按这个值给出 `noMore` 或 `success`。第一页已经装完时，刷新结束后会把 Footer 锁成 `noMore`。

```dart
class CustomPaging extends FastPaging<List<String>, String> {
  const CustomPaging({super.key, super.refreshOnStart = true, super.itemBuilder});

  @override
  FastPagingState<List<String>, String, CustomPaging> createState() =>
      _CustomPagingState();
}

class _CustomPagingState
    extends FastPagingState<List<String>, String, CustomPaging> {
  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) => data![index];

  @override
  int? page;

  @override
  int? total;

  @override
  int? totalPage;

  @override
  Widget buildItem(BuildContext context, int index, String item) {
    return buildItemByBuilder(context, index, item);
  }

  @override
  Future<FastRefreshResult?> onRefresh() async {
    final first = await fetchPage(1);
    setState(() {
      data = first.items;
      page = first.page;
      total = first.total;
    });
    return null;
  }

  @override
  Future<FastRefreshResult?> onLoad() async {
    final next = await fetchPage(page! + 1);
    setState(() {
      data = <String>[...data!, ...next.items];
      page = next.page;
      total = next.total;
    });
    return null;
  }
}
```

| 要点 | 说明 |
| --- | --- |
| 默认构造 | `useDefaultPhysics: false`，走 `FastRefresh.builder`，physics 挂到内部 `CustomScrollView` |
| Widget 构造 | `useDefaultPhysics: true`，适合单列表、没有嵌套滚动 |
| 空态 | `isEmpty` 时用 `emptyWidgetBuilder` 或覆写 `buildEmptyWidget` |
| 进入页 | `refreshOnStart` + `refreshOnStartWidgetBuilder` |
| Locator | Header / Footer 的 `position` 为 `locator` 时自动插入 Locator sliver |

完整演示见 example 的 `refresh_example/paging`（45 条、每页 10 条，可切空态和 Widget 构造）。

---

## 上拉加载与滚动 {#load-more}

触底加载时，用户往往还在上滑，`onLoad` 又把新数据 push 进列表。掉帧通常不是「多了几条」，而是**惯性还在滑，列表高度每一帧都在变**，物理层的弹簧被反复掐断重来。

库里已经做了这些：

| 优化 | 行为 |
| --- | --- |
| 不打断范围内的惯性 | 新数据把 `maxScrollExtent` 撑高、像素已经回到范围内时，不再只因为 Footer 还在 `processing` 就 `goBallistic` |
| 结束后按需回弹 | `processed` 收尾只在仍越界时重瞄弹簧；已经滑进新内容则保持当前惯性 |
| 位置稳住 | 列表变高、离开越界后，Footer offset 清掉，像素不被弹簧拽走 |

和 [Animated List](/ui/animated-list#load-more) 组合时，加载中或列表还在滑的**尾部追加**不做动画、立刻到位，避免 `SizeTransition` 每帧改高度。列表静止时的批量插入仍走错开动画。`FastPagingList`（普通 `SliverList`）也会吃到上表，不只是动画列表。

业务侧还能再减一帧成本：

- 行高固定时用 `itemExtent` / `prototypeItem`
- tile 用稳定 `ValueKey` / `itemId`，避免整表重建
- 单页不要一次 push 太多；图片不要在插入当帧同步解码

完整组合见 example 的 `animated_list_example`「配合 Refresh」。

---

## 横向 {#horizontal}

把列表改成横滑即可，不必换物理。Classic Header / Footer 会转到左右两侧。

```dart
FastRefresh(
  clipBehavior: Clip.none,
  header: const FastClassicHeader(),
  footer: const FastClassicFooter(infiniteOffset: null),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: items.length,
    itemBuilder: (_, i) => SizedBox(width: 220, child: Text(items[i])),
  ),
);
```

| 要点 | 说明 |
| --- | --- |
| `scrollDirection` | `Axis.horizontal` 时，Header 在左、Footer 在右（正向列表） |
| `triggerAxis` | 可选。设为 `Axis.horizontal` 时只响应横轴；`null` 表示不限制 |
| `PageView` | 必须把 Footer 的 `infiniteOffset` 设为 `null`，否则一翻页就 `onLoad` |
| `clipBehavior` | 指示器画在视口外时用 `Clip.none` |

完整切换见 example 的 `refresh_example/horizontal`（AppBar 可在 `ListView` 与 `PageView` 之间切换）。

---

## 二楼 {#secondary}

拉过普通刷新阈值后继续拉，打开接近全屏的第二页。内核已有状态机，页面用 `FastSecondaryBuilderHeader` 叠内容。

```
inactive → drag → armed → …          普通刷新
                 ↘ secondaryArmed → secondaryReady → secondaryOpen
                                                      ↓
                                              secondaryClosing → inactive
```

| 参数 | 说明 |
| --- | --- |
| `secondaryTriggerOffset` | 二楼触发距离，必须大于 `triggerOffset` |
| `secondaryDimension` | 二楼打开后的高度，默认视口高 |
| `secondaryVelocity` | 松手后吸开二楼的速度，默认 3000 |
| `secondaryCloseTriggerOffset` | 上推多少后开始关楼，默认 70 |

`secondaryTriggerOffset` 不能和 `infiniteOffset` 同时用（Header 默认没有无限刷新，不要给二楼 Header 开无限）。

```dart
FastRefresh(
  clipBehavior: Clip.none,
  controller: controller,
  header: FastSecondaryBuilderHeader(
    header: const FastClassicHeader(
      position: FastRefreshIndicatorPosition.locator,
      clipBehavior: Clip.none,
      safeArea: false,
    ),
    secondaryTriggerOffset: 120,
    secondaryDimension: screenHeight - kToolbarHeight - topPadding,
    listenable: listenable,
    builder: (context, state, header) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(height: state.offset, width: double.infinity),
          // 二楼页：高度用屏幕高，透明度跟手势
          header.build(context, state),
        ],
      );
    },
  ),
  child: CustomScrollView(
    slivers: [
      // 用 listenable 同步 SliverAppBar
      const FastHeaderLocator.sliver(),
      // 列表
    ],
  ),
);
```

打开 / 关闭：

- 手势：拉过 `secondaryTriggerOffset` 再松手
- 编程：`controller.openHeaderSecondary()` / `closeHeaderSecondary()`
- 返回键：二楼打开时用 `PopScope(canPop: false)` 调 `closeHeaderSecondary()`

`FastRefresh.clipBehavior` 必须是 `Clip.none`，否则高出 trigger 的二楼页会被裁掉。完整配方见 example 的 `refresh_example/secondary`。

---

## Material {#material}

默认皮肤仍是 Classic。要系统下拉那种月牙转圈，换 `FastMaterialHeader`（默认 `clamping: true`）。`FastMaterialFooter` 用 `CircularProgressIndicator`，默认仍触底加载（`infiniteOffset: 70`，`clamping` 为 false，与现有「clamping 不能搭配无限加载」约束一致）。

```dart
FastRefresh(
  header: const FastMaterialHeader(),
  footer: const FastMaterialFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
);
```

---

## Theme {#theme}

`FastRefreshTheme` 是 `ThemeExtension`。Classic 文案 / 样式与 Material 颜色按「构造参数 → Theme → light/dark 英文默认」解析。不改变触发距离或弹簧。

```dart
ThemeData(
  extensions: [
    FastRefreshTheme(
      headerTexts: FastRefreshIndicatorTexts(
        dragText: '下拉刷新',
        armedText: '释放刷新',
        readyText: '正在刷新...',
        processingText: '正在刷新...',
        processedText: '刷新成功',
        noMoreText: '没有更多了',
        failedText: '刷新失败',
        messageText: '上次更新 %T',
      ),
      footerTexts: FastRefreshIndicatorTexts.footerEnglish.copyWith(
        dragText: '上拉加载',
        noMoreText: '没有更多了',
      ),
      indicatorColor: Colors.blue,
    ),
  ],
)
```

未挂 Theme 时 Classic 仍是英文默认（`Pull to refresh`）。

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
