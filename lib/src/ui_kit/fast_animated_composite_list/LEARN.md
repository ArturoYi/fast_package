# FastAnimatedCompositeList 实现学习指南

给自己读的笔记，不进对外文档站。用法演示见 `example/lib/pages/animated_list_example/` 和 `docs/ui/animated-list.md`。

设计 Space 见同目录 [`SPACE.md`](SPACE.md)。**以当前 `lib` 代码为准。**

核心不是「给 ListView 套一层 fade」，而是：**identity diff 驱动 AnimatedList，拖拽只用 hover 通知，入场共用一个 ticker。**

## 总图

```
items 变更
  → FastListDiff（快路径 + budget）
  → SliverAnimatedList.insertItem / removeItem
  → FastListMutationTransition（Size + Fade，Grid 用 Scale + Fade）

首屏
  → 列表级 AnimationController
  → FastStaggerSlot Interval(position)
  → 首帧后 limiter，滚入不再播

拖拽
  → 长按 / Handle
  → OverlayPortal 代理（ValueNotifier<Offset> 每像素）
  → hoverIndex 变化才 notify item
  → 松手 onReorder（Flutter 约定）
  → 零时长 move 对齐 AnimatedList
```

对应文件分工：

| 层 | 文件 | 职责 |
| --- | --- | --- |
| 组装 | `widgets/fast_animated_list.dart` 等 | 三个对外入口，只设 `animateMutations` / `enableReorder` |
| 核心 | `widgets/fast_animated_composite_core.dart` | diff 应用、首屏 ticker、Refresh 锁 |
| 入场 | `animation/fast_list_stagger.dart`、`fast_animated_list_transition.dart` | 错开公式、Limiter、mutation / entrance |
| Diff | `animation/fast_list_diff.dart` | 增删、单元素 move、超预算 reset |
| 拖拽 | `drag/fast_list_drag_coordinator.dart`、`fast_list_geometry.dart` | hover、几何、代理位移 |
| 控制 | `controller/fast_animated_composite_list_controller.dart` | `isAnimating` / `isDragging` |
| 外观 | `theme/fast_animated_composite_list_theme.dart` | ThemeExtension |

## 需要掌握的知识

- **`SliverAnimatedList` / `SliverAnimatedGrid`**：`initialItemCount` 首屏不播增删；之后只对 diff 结果 `insertItem` / `removeItem`。move 用零时长 remove+insert，避免拖完再播一遍入场。
- **`findChildIndexCallback` + `ValueKey(id)`**：排序后 Element 复用，item 内部 State（例如 `FastSlidable`）不丢。
- **共享 ticker + `Interval`**：不要抄参考库的 per-item `AnimationController` + `Timer`。
- **Limiter 捕获在 slot 的 `didChangeDependencies` 首次调用**：`updateShouldNotify` 把 `limitNewItems` 翻成 true 时，已建 slot 不得改 `_play`。
- **拖拽双通道**：指针位移只推 `ValueNotifier<Offset>`（Overlay）；`DragCoordinator.notifyListeners` 仅在 `dragIndex` / `hoverIndex` 变化时调用。
- **`onReorder` 约定**：与 `ReorderableListView` 相同。内部乐观更新 `_ids` 用未 +1 的 `hover`。
- **Controller 所有权**：`widget.controller ?? _ownedController`。换外部实例不 dispose；自建实例在本帧结束再毁。
- **`FastRefresh.maybeOf`**：下拉或 Header / Footer 非 `inactive` 时取消拖拽。

## 为什么增删和拖拽要拆开

`SliverAnimatedList` 没有 `moveItem`，`SliverReorderableList` 没有增删动画，两者不能叠。拆成两个入口后，只要其中一边的调用方不必为另一边付代价；组合入口在同一套 `_ids` 上协调「拖的时候不要当增删」。

## 和 FastRefresh / FastSlidable 的边界

日常组合：竖直 Refresh + 本列表 + 水平 Slidable。同轴（横向 Refresh + 横向拖拽）第一版不做手势仲裁。不把本列表焊进 `FastPagingList`，在 `itemBuilder` 或 `FastRefresh.builder` 的 sliver 里组合。
