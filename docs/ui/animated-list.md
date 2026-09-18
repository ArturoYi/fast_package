---
title: Animated List 动画列表
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_animated_composite_list" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_animated_composite_list/</code>
</p>

<DocCredit module="animated-list" />

## 概览 {#overview}

增删动画和拖拽排序是两个独立组件，需要两者时用组合入口。`items` 一变就按 `itemId` 做 diff；首屏错开用**一个**列表级 ticker，滚入视野不再播。

| 要点 | 说明 |
| --- | --- |
| 只增删 | `FastAnimatedList` / `FastSliverAnimatedList` |
| 只排序 | `FastReorderableList` / `FastSliverReorderableList` |
| 组合 | `FastAnimatedCompositeList` / `FastSliverAnimatedCompositeList` |
| 入场 | `FastListStagger.list / grid / synchronized / none`；Column 用 `FastStagger` |
| 拖拽 | 默认长按；或 `FastListDragTrigger.handle` + `FastListDragHandle` |
| 主题 | `FastAnimatedCompositeListTheme`（`ThemeExtension`） |
| **不做** | per-item `AnimationController`、分隔线 API、侵入 `FastPagingList`、跨列表拖拽 |

::: tip
`itemId` 必须稳定且唯一。`onReorder` 对齐 `ReorderableListView`：`oldIndex < newIndex` 时先 `newIndex -= 1` 再 `insert`。完整演示见 example 的 `AnimatedListExample` 页。
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

## 组合入口 {#composite}

```dart
FastAnimatedCompositeList<Note>(
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

默认列表用 `FastListStagger.list()`，固定列网格用 `FastListStagger.grid(columnCount: n)`。delay 公式与 flutter_staggered_animations 相同：列表 `position * delay`，网格 `(row + col) * delay`，`delay` 默认是 duration / 6。

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

超过 `animationBudget`（默认 24）的大改动（例如整表刷新）会零时长对齐，避免 N 段动画卡死。

---

## 和 Refresh / Slidable {#compose}

竖直 `FastRefresh` 下拉或 Header / Footer 非 `inactive` 时锁住拖拽。水平 `FastSlidable` 包在 `itemBuilder` 里即可，不要焊进 `FastPagingList` API。

同轴（横向 Refresh + 横向拖拽）第一版不做手势仲裁。默认长按才拖，避免和列表滚动抢手势。
