# FastAnimatedList 实现学习指南

给自己读的笔记，不进对外文档站。用法演示见 `example/lib/pages/animated_list_example/` 和 `docs/ui/animated-list.md`。

设计 Space 见同目录 [`SPACE.md`](SPACE.md)。**以当前 `lib` 代码为准。**

核心不是「给 ListView 套一层 fade」，而是：**按 `itemId` 算出增删，再交给 AnimatedList；拖拽只在 `hoverIndex` 变化时通知；入场共用一个 `AnimationController`。**

## 总图

```
items 变更
  → FastListDiff（快路径 + animationBudget）
  → SliverAnimatedList.insertItem / removeItem
  → FastListMutationTransition（Size + Fade，Grid 用 Scale + Fade）
  → 同一批发插入按 stagger.delayFor(ordinal) 拉长 duration，Interval 错开起点

首屏
  → 列表级 AnimationController
  → FastStaggerSlot Interval(position)
  → 首帧后，后滚进来的项不再播入场

拖拽
  → 长按 / Handle
  → OverlayPortal 代理（ValueNotifier<Offset> 每像素）
  → hoverIndex 变化才 notify item
  → 松手 onReorder（Flutter 约定）
  → move 用 duration 为 0 的 remove + insert
```

对应文件分工：

| 层 | 文件 | 职责 |
| --- | --- | --- |
| 组装 | `widgets/fast_animated_list.dart` 等 | 三个对外入口，只设 `animateMutations` / `enableReorder` |
| 核心 | `widgets/fast_list_core.dart` | 应用 diff、首屏 `AnimationController`、Refresh 锁 |
| 入场 | `animation/fast_list_stagger.dart`、`fast_animated_list_transition.dart` | 错开公式、限制滚入再播、增删 / 入场过渡 |
| Diff | `animation/fast_list_diff.dart` | 增删、单元素 move、超预算整表立刻到位 |
| 拖拽 | `drag/fast_list_drag_coordinator.dart`、`fast_list_geometry.dart` | hover、几何、代理位移 |
| 控制 | `controller/fast_animated_list_controller.dart` | `isAnimating` / `isDragging` |
| 外观 | `theme/fast_animated_list_theme.dart` | ThemeExtension |

## 需要掌握的知识

- **`SliverAnimatedList` / `SliverAnimatedGrid`**：`initialItemCount` 首屏不播增删；之后只对 diff 结果 `insertItem` / `removeItem`。move 用 duration 为 0 的 remove + insert，避免拖完再播一遍入场。静止时的批量插入按 `FastListStagger.delayFor(ordinal)` 错开。上拉加载或列表还在滑时的尾部追加不做动画、立刻到位：`SizeTransition` 会每帧改 `maxScrollExtent`，FastRefresh 的 `goBallistic` 会被掐断重来，惯性掉帧。
- **`findChildIndexCallback` + `ValueKey(id)`**：排序后 Element 复用，item 内部 State（例如 `FastSlidable`）不丢。
- **共用一个 `AnimationController` + `Interval`**：不要给每个 item 建 `AnimationController` + `Timer`。
- **是否播放入场，在 slot 的 `didChangeDependencies` 第一次调用时定下来**：`updateShouldNotify` 把 `limitNewItems` 翻成 true 时，已经建好的 slot 不得改 `_play`。
- **拖拽分两路**：指针位移只推 `ValueNotifier<Offset>`（Overlay）；`DragCoordinator.notifyListeners` 仅在 `dragIndex` / `hoverIndex` 变化时调用。
- **量槽位几何必须在让位 Transform 之上**：`_boxKey` 挂在 `_SlotLayoutBox`（`Listener`）上，`localToGlobal` 才是布局槽。若量到 `_ShiftedBox` 的 `RenderTransform`，hover 会跟着兄弟跳，手柄排序看起来像坏了。
- **手柄按下就赢下手势**：`FastListDragHandle` 用立刻 `accept` 的 `OneSequenceGestureRecognizer`，避免父级 `Scrollable` 抢走纵向拖；过 slop 才出代理。
- **`onReorder` 约定**：与 `ReorderableListView` 相同。内部乐观更新 `_ids` 用未 +1 的 `hover`。
- **Controller 所有权**：`widget.controller ?? _ownedController`。换外部实例不 dispose；自建实例在本帧结束再毁。
- **`FastRefresh.maybeOf`**：下拉或 Header / Footer 非 `inactive` 时取消拖拽。锁只在起拖时读，手指按下不要整表 `setState`（否则每滑一次拆掉长按手势，和下拉刷新叠在一起会卡）。增删过渡层保持挂着，避免侧滑删除后再套 `SizeTransition` 把行卸掉重挂、看起来像播两遍。

## 为什么增删和拖拽要拆开

`SliverAnimatedList` 没有 `moveItem`，`SliverReorderableList` 没有增删动画，两者不能叠。拆成两个入口后，只要其中一边的调用方不必为另一边付代价；`FastAnimatedReorderableList` 在同一套 `_ids` 上协调「拖的时候不要当增删」。

## 和 FastRefresh / FastSlidable 的边界

日常组合：竖直 Refresh + 本列表 + 水平 Slidable。同一方向（横向 Refresh + 横向拖拽）第一版不处理手势冲突。不要把本列表写进 `FastPagingList` 的 API，在 `itemBuilder` 或 `FastRefresh.builder` 的 sliver 里组合。
