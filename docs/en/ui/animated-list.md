---
title: Animated List
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_animated_list" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_animated_list/</code>
</p>

## Overview {#overview}

Insert/remove animation and drag reorder are separate widgets. Use `FastAnimatedReorderableList` when you need both. Changing `items` diffs by `itemId`. First-frame stagger uses **one** list-level ticker; items that scroll into view later do not play. Idle batch inserts in a later diff are staggered with the same delay formula; a tail append during load-more or an in-flight scroll snaps with zero duration.

| Topic | Notes |
| --- | --- |
| Mutations only | `FastAnimatedList` / `FastSliverAnimatedList` |
| Reorder only | `FastReorderableList` / `FastSliverReorderableList` |
| Both | `FastAnimatedReorderableList` / `FastSliverAnimatedReorderableList` |
| Entrance | `FastListStagger.list / grid / synchronized / none`; `FastStagger` for a Column |
| Drag | Long-press by default, or `FastListDragTrigger.handle` + `FastListDragHandle` |
| Theme | `FastAnimatedListTheme` (`ThemeExtension`) |
| **Not provided** | Per-item `AnimationController`, separator API, baking into `FastPagingList`, cross-list drag |

::: tip
`itemId` must be stable and unique. `onReorder` matches `ReorderableListView`: subtract one from `newIndex` when `oldIndex < newIndex` before inserting. The example app’s `AnimatedListExample` covers insert/remove (including batch), drag, both, Refresh, Slidable, and Refresh+Slidable. Each scene switches List / Sliver / Column and list / grid.
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

## Insert, remove, and reorder {#reorderable}

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

Use the sliver variants inside `CustomScrollView` or `FastRefresh.builder`.

---

## First-frame stagger {#stagger}

Lists default to `FastListStagger.list()`. Fixed-column grids use `FastListStagger.grid(columnCount: n)`. Lists use `position * delay`; grids use `(row + col) * delay`. `delay` defaults to duration / 6.

The first frame uses one shared ticker sliced by position. Idle batch inserts do not pop in as a block: the `n`th insert in the same diff waits `delayFor(n)` before its mutation animation. Positions above `maxItems` share the last delay. `FastListStagger.none()` and `synchronized()` still start together. Tail appends during load-more are covered in [Load-more and scrolling](#load-more).

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

## Load-more and scrolling {#load-more}

A `SizeTransition` that grows from 0 rewrites `maxScrollExtent` every frame. If the user is still flinging and FastRefresh is `processing`, the physics layer keeps calling `goBallistic` and the list stutters.

A tail append (`FastListDiff.isTailAppend`: contiguous inserts after existing items) therefore **snaps with zero duration** in these cases:

| When | Behavior |
| --- | --- |
| Header / Footer is not `inactive`, or the pointer is down | Treated as refresh / load-more; no `SizeTransition` on the tail |
| The list `isScrollingNotifier` is true | An in-flight fling also snaps |

Idle “batch +N” from a toolbar still staggers. A full-table refresh over `animationBudget` already snaps.

FastRefresh also keeps an in-range fling after the list grows. See [Refresh · Load-more and scrolling](/en/ui/refresh#load-more).

App-side tips:

- Pass `itemExtent` when row height is fixed
- Keep `itemId` stable so tiles do not drop State on append
- Do not push a huge page in one shot; decode large images asynchronously

The combined recipe is the “Refresh” scene under `animated_list_example`.

---

## Refresh and Slidable {#compose}

A vertical `FastRefresh` locks drag while the user is pulling or Header / Footer is not `inactive`. The lock is checked when a drag starts; tiles are not rebuilt on finger-down. Wrap `FastSlidable` in `itemBuilder`; do not bake this list into `FastPagingList`. Tail appends during load-more are covered in [Load-more and scrolling](#load-more).

Same-axis horizontal Refresh + horizontal drag is not arbitrated in v1. Long-press-to-drag is the default so scrolling wins the gesture arena.
