---
title: Animated List
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_animated_composite_list" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_animated_composite_list/</code>
</p>

<DocCredit module="animated-list" />

## Overview {#overview}

Insert/remove animation and drag reorder are separate widgets. Use the composite when you need both. Changing `items` diffs by `itemId`. First-frame stagger uses **one** list-level ticker; items that scroll into view later do not play.

| Topic | Notes |
| --- | --- |
| Mutations only | `FastAnimatedList` / `FastSliverAnimatedList` |
| Reorder only | `FastReorderableList` / `FastSliverReorderableList` |
| Both | `FastAnimatedCompositeList` / `FastSliverAnimatedCompositeList` |
| Entrance | `FastListStagger.list / grid / synchronized / none`; `FastStagger` for a Column |
| Drag | Long-press by default, or `FastListDragTrigger.handle` + `FastListDragHandle` |
| Theme | `FastAnimatedCompositeListTheme` (`ThemeExtension`) |
| **Not provided** | Per-item `AnimationController`, separator API, baking into `FastPagingList`, cross-list drag |

::: tip
`itemId` must be stable and unique. `onReorder` matches `ReorderableListView`: subtract one from `newIndex` when `oldIndex < newIndex` before inserting. See the example app’s `AnimatedListExample` page.
:::

---

## Insert and remove {#basic}

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

Grid:

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

## Reorder only {#reorder}

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

## Composite {#composite}

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

Use the sliver variants inside `CustomScrollView` or `FastRefresh.builder`.

---

## First-frame stagger {#stagger}

Lists default to `FastListStagger.list()`. Fixed-column grids use `FastListStagger.grid(columnCount: n)`. Delay math matches flutter_staggered_animations: `position * delay` on a list, `(row + col) * delay` on a grid, with `delay` defaulting to duration / 6.

Entrance without a diff:

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

Edits larger than `animationBudget` (default 24)—for example a full refresh—snap with zero duration so the UI does not run N animations.

---

## Refresh and Slidable {#compose}

A vertical `FastRefresh` locks drag while the user is pulling or Header / Footer is not `inactive`. Wrap `FastSlidable` in `itemBuilder`; do not bake this list into `FastPagingList`.

Same-axis horizontal Refresh + horizontal drag is not arbitrated in v1. Long-press-to-drag is the default so scrolling wins the gesture arena.
