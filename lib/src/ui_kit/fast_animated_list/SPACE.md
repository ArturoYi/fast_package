# FastAnimatedList 设计 Space

给自己改方案用，不上文档站。对外用法见 `docs/ui/animated-list.md`；实现怎么读见同目录 `LEARN.md`。**以当前 `lib` 代码为准。**

增删走 Flutter `SliverAnimatedList` / `SliverAnimatedGrid`，拖拽自己写。对齐 UI Kit：**零第三方依赖、核心手写、主题走 `ThemeExtension`、文档写清「不做」**。

覆盖场景：列表 / 网格第一次出现时逐条错开入场、items 变化时的插入 / 删除、长按或手柄拖拽排序、和竖直 FastRefresh / FastSlidable 一起用。

SDK 必须兼容根目录 `pubspec.yaml`：Dart `>=3.3.4`，Flutter `>=3.19.6`。不要用 `Color.withValues`（3.27+），沿用 `withOpacity`。不要用 `AnimatedList.separated`（3.27+）。

## 公开 API：两个独立组件 + 增删排序入口

```dart
// 1) 只做增删 / 入场
FastAnimatedList<T>(
  items: items,
  itemId: (e) => e.id,
  itemBuilder: (context, item, index) => tile,
  stagger: FastListStagger.list(),
)

// 2) 只做拖拽排序
FastReorderableList<T>(
  items: items,
  itemId: (e) => e.id,
  onReorder: (from, to) { /* Flutter 约定：from < to 时 to-- */ },
  itemBuilder: (context, item, index) => tile,
)

// 3) 增删 + 排序
FastAnimatedReorderableList<T>(
  items: items,
  itemId: (e) => e.id,
  onReorder: onReorder,
  itemBuilder: (context, item, index) => tile,
)
```

Sliver 变体：`FastSliverAnimatedList` / `FastSliverReorderableList` / `FastSliverAnimatedReorderableList`。网格用 `.grid(gridDelegate: ...)`。

Column / 自建 ListView 只要入场、不要 diff 时用 `FastStagger` + `FastStagger.item`。

## 设计要点

1. **改 items 就行，不用手写 insertItem**  
   调用方 `setState` 改列表，核心按 `itemId` 算出增删。超过 `animationBudget` 的大改动（整表刷新）不做动画、立刻到位，避免一次播太多动画卡死。

2. **拖拽不跟增删抢同一套 sliver**  
   独立组件可以只用 SDK `SliverAnimatedList`，或只用拖拽层。`FastAnimatedReorderableList` 共用 `FastListCore`：增删仍走 AnimatedList，拖拽用 Overlay 代理 + `hoverIndex` 通知（**不是每像素重建 item**）。

3. **和 FastRefresh / FastSlidable 一起用**  
   默认长按才拖，不跟竖直滚动 / 下拉刷新抢手势。刷新进行中（`userOffsetNotifier` 或 Header / Footer 非 `inactive`）锁拖拽，但只在开始拖的时候检查，不要为了锁整表 `setState`。水平 `FastSlidable` 包在 `itemBuilder` 里即可，不要写进 `FastPagingList` 的 API。

4. **Controller 生命周期对齐 FastSlidableController**  
   外部传入则调用方 `dispose`；未传入则 State 自建自毁。只暴露 `isAnimating` / `isDragging`，items 仍由调用方持有。

5. **入场共用一个 `AnimationController`**  
   item 用 `Interval` 切片；不要给每个 child 建 `AnimationController`。入场组件在 `initState` / `didChangeDependencies` 里记下「是否播放」，避免 `limitNewItems` 翻转时打断第一屏。不导出一层套一层的入场包装；入场是枚举 + 可选 `transitionBuilder`。

## 已拍板

- `onReorder` 对齐 Flutter `ReorderableListView`：`oldIndex < newIndex` 时先 `newIndex -= 1` 再 `insert`。
- 拖拽触发：`longPress`（默认）或 `handle`（`FastListDragHandle`）。
- 首屏错开默认开启，滚进来的不再播。
- 静止时的批量插入按同一套 stagger delay 逐条错开。上拉加载 / 还在滑时的尾部追加不做动画、立刻到位，避免 `SizeTransition` 和 FastRefresh 弹簧抢同一条惯性。
- item 必须有稳定且唯一的 `itemId`。不靠 `==` 判断是不是同一条。

## 不做

- 不给每个 child 建 `AnimationController`
- 不提供 `AnimatedList.separated` 兼容层；分割线放进 tile
- 不把本组件写进 `FastPagingList` 的 API
- 不做多指拖拽、跨列表拖拽、鼠标 hover 露出手柄
- 不保证水平 Refresh 与水平拖拽同一方向共存
- 不靠 `==` 判断同一条（必须 `itemId`）

## 内部结构

```mermaid
flowchart TB
  items[widget.items]
  diff[FastListDiff]
  animated[SliverAnimatedList / Grid]
  stagger[shared AnimationController]
  drag[DragCoordinator hoverIndex]
  overlay[OverlayPortal proxy]
  refresh[FastRefreshData]

  items --> diff
  diff -->|"insert/remove/move"| animated
  stagger -->|"Interval per index"| items
  drag -->|"only on index change"| items
  overlay -->|"pointer pixels"| drag
  refresh -->|"lock drag"| drag
```

文件在 `lib/src/ui_kit/fast_animated_list/`：

- `fast_animated_list.dart` 入口
- `controller/` `theme/` `animation/` `drag/` `widgets/`
- `LEARN.md`、`SPACE.md`

导出在 `lib/fast_package.dart`。文档 `docs/ui/animated-list.md` + `docs/en/ui/animated-list.md`。示例 `example/lib/pages/animated_list_example/`。测试 `test/fast_animated_list_test/`。
