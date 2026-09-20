---
title: Animated List 动画列表
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_animated_list" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_animated_list/</code>
</p>

## 概览 {#overview}

增删动画和拖拽排序是两个独立组件，需要两者时用 `FastAnimatedReorderableList`。`items` 一变就按 `itemId` 算出增删；首屏错开用**一个**列表共用的 `AnimationController`，滚入视野不再播。列表静止时的批量插入按同一套 delay 逐条进场；上拉加载或还在滑时的尾部追加不做动画、立刻到位。

| 要点 | 说明 |
| --- | --- |
| 只增删 | `FastAnimatedList` / `FastSliverAnimatedList` |
| 只排序 | `FastReorderableList` / `FastSliverReorderableList` |
| 增删 + 排序 | `FastAnimatedReorderableList` / `FastSliverAnimatedReorderableList` |
| 入场 | `FastListStagger.list / grid / synchronized / none`；Column 用 `FastStagger` |
| 拖拽 | 默认长按；或 `FastListDragTrigger.handle` + `FastListDragHandle` |
| 主题 | `FastAnimatedListTheme`（`ThemeExtension`） |
| **不做** | 不给每个 item 建 `AnimationController`、分隔线 API、写进 `FastPagingList`、跨列表拖拽 |

::: tip
`itemId` 必须稳定且唯一。`onReorder` 对齐 `ReorderableListView`：`oldIndex < newIndex` 时先 `newIndex -= 1` 再 `insert`。完整演示见 example 的 `AnimatedListExample`：增删 / 批量增删、拖拽、增删+拖拽、Refresh、Slidable、Refresh+Slidable；每个场景可切 List / Sliver / Column 以及列表 / 网格。
:::

---

## 基础增删 {#basic}

```dart
import 'package:fast_package/fast_package.dart';

FastAnimatedList<Note>(
  items: notes,
  itemId: (Note e) => e.id,
  itemBuilder: (context, item, index) {
    return ListTile(
      title: Text(item.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => setState(() => notes.removeAt(index)),
      ),
    );
  },
)
```

网格：

```dart
FastAnimatedList<Note>.grid(
  items: notes,
  itemId: (Note e) => e.id,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  itemBuilder: (context, item, index) => NoteCard(item: item),
)
```

---

## 只排序 {#reorder}

```dart
FastReorderableList<Note>(
  items: notes,
  itemId: (Note e) => e.id,
  onReorder: (int from, int to) {
    setState(() {
      if (from < to) {
        to -= 1;
      }
      notes.insert(to, notes.removeAt(from));
    });
  },
  itemBuilder: (context, item, index) => ListTile(title: Text(item.title)),
)
```

---

## 增删 + 排序 {#reorderable}

```dart
FastAnimatedReorderableList<Note>(
  items: notes,
  itemId: (Note e) => e.id,
  dragTrigger: FastListDragTrigger.handle,
  onReorder: (int from, int to) {
    setState(() {
      if (from < to) {
        to -= 1;
      }
      notes.insert(to, notes.removeAt(from));
    });
  },
  itemBuilder: (context, item, index) {
    return ListTile(
      leading: const FastListDragHandle(child: Icon(Icons.drag_handle)),
      title: Text(item.title),
    );
  },
)
```

嵌进 `CustomScrollView` / `FastRefresh.builder` 用 sliver 变体。

---

## 首屏错开 {#stagger}

默认列表用 `FastListStagger.list()`，固定列网格用 `FastListStagger.grid(columnCount: n)`。列表 delay 是 `position * delay`，网格是 `(row + col) * delay`，`delay` 默认是 duration / 6。

首屏用共用的 `AnimationController` 按 position 切 `Interval`。列表静止时的批量插入不会整页同时弹出：同一 diff 里的第 `n` 条 insert 先等 `delayFor(n)`，再播自己的增删动画。超过 `maxItems` 的项共用最后一档 delay。`FastListStagger.none()` / `synchronized()` 仍是同时开播。上拉加载时的尾部追加见 [上拉加载与滚动](#load-more)。

只要入场、不要 diff 时：

```dart
FastStagger(
  stagger: const FastListStagger.list(),
  child: Column(
    children: FastStagger.children(
      children: tiles,
    ),
  ),
)
```

超过 `animationBudget`（默认 24）的大改动（例如整表刷新）不做动画、立刻到位，避免一次播太多动画卡死。

---

## 上拉加载与滚动 {#load-more}

`SizeTransition` 从 0 长高时，每一帧都会改 `maxScrollExtent`。用户还在上滑、FastRefresh 又在 `processing` 时，物理层会反复 `goBallistic`，列表发涩、掉帧。

因此尾部追加（`FastListDiff.isTailAppend`，现有条目后面的连续 insert）在下面两种情况**不做动画、立刻到位**，高度一次到位：

| 条件 | 行为 |
| --- | --- |
| Footer / Header 非 `inactive`，或手指还按着 | 视为加载 / 刷新进行中，尾部追加不播 `SizeTransition` |
| 列表 `isScrollingNotifier` 为 true | 惯性还在，同样立刻到位 |

列表完全静止时的「批量 +N」（工具栏那种）仍走错开动画。整表刷新超过 `animationBudget` 本来就会立刻到位。

Refresh 一侧还会在内容变高、已经回到范围内时不打断惯性，见 [Refresh · 上拉加载与滚动](/ui/refresh#load-more)。

业务侧建议：

- 行高固定时传 `itemExtent`
- `itemId` 稳定，tile 不要在追加时丢掉 State
- 单页条目不要一次塞太多；大图异步解码

完整组合见 example 的 `animated_list_example`「配合 Refresh」。

---

## 和 Refresh / Slidable {#compose}

竖直 `FastRefresh` 下拉或 Header / Footer 非 `inactive` 时锁住拖拽（起拖时检查，不整表 `setState`）。水平 `FastSlidable` 包在 `itemBuilder` 里即可，不要写进 `FastPagingList` 的 API。上拉加载时的尾部追加见 [上拉加载与滚动](#load-more)。

同一方向（横向 Refresh + 横向拖拽）第一版不处理手势冲突。默认长按才拖，避免和列表滚动抢手势。
