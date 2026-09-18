---
title: Slidable
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_slidable" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_slidable/</code>
</p>

<DocCredit module="slidable" />

## Overview {#overview}

`FastSlidable` reveals contextual actions when a row is dragged horizontally or vertically. A longer swipe can fire the primary action and dismiss the row. A controller opens and closes the pane from code. Combined with a vertical `FastRefresh` / `FastPagingList`, dragging or processing a refresh locks the slide.

| Topic | Notes |
| --- | --- |
| Entry | `FastSlidable(startPane, endPane, child)` |
| Pane | `FastSlidablePane` + `FastSlidableAction` |
| Motion | `FastSlidableMotion.behind / drawer / scroll` |
| Dismiss | `FastSlidableDismiss`; full swipe via `FastSlidableFullSwipe` |
| Group | `FastSlidableGroup` + `groupTag` |
| Theme | `FastSlidableTheme` (`ThemeExtension`) |
| **Not provided** | Legacy notification APIs, inferring actions from `child`, same-axis horizontal Refresh + Slidable, baking Slidable into `FastPagingList` |

::: tip
If `dismiss` or a dismissing `fullSwipe` is set, `FastSlidable` **must** have a `key`. See the example app’s `SlidableExample` page.
:::

---

## Basic usage {#basic}

```dart
import 'package:fast_package/fast_package.dart';

FastSlidableGroup(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return FastSlidable(
        key: ValueKey(item.id),
        groupTag: 'inbox',
        startPane: FastSlidablePane(
          motion: FastSlidableMotion.scroll,
          children: [
            FastSlidableAction(
              onPressed: (_) => share(item),
              backgroundColor: Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
            ),
          ],
        ),
        endPane: FastSlidablePane(
          motion: FastSlidableMotion.drawer,
          dismiss: FastSlidableDismiss(onDismissed: () => remove(item)),
          fullSwipe: FastSlidableFullSwipe(threshold: 0.55),
          children: [
            FastSlidableAction(
              onPressed: (_) => archive(item),
              backgroundColor: Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archive',
            ),
            FastSlidableAction(
              onPressed: (_) => remove(item),
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(title: Text(item.title)),
      );
    },
  ),
)
```

In LTR, `startPane` is the left side (top when vertical) and `endPane` is the right side (bottom when vertical). With `useTextDirection: true`, RTL flips them.

---

## Motion {#motion}

`FastSlidablePane.motion`:

| Value | Effect |
| --- | --- |
| `behind` | Actions sit behind the child |
| `drawer` | Actions enter like stacked drawers |
| `scroll` | Actions travel with the child (default) |

Pass `motionBuilder` for a fully custom reveal.

---

## Full swipe and dismiss {#dismiss}

Two stages:

1. Release inside `extentRatio`: `openThreshold` / `closeThreshold` decide open vs close
2. Drag past `fullSwipe.threshold`: the primary action expands; release fires it. `dismiss: true` then shrinks the row

To delete only after a long swipe, set `FastSlidableDismiss` without a full swipe.

The primary action defaults to the first child on the start pane and the last child on the end pane. Override with `fullSwipe.primaryIndex`.

---

## Controller {#controller}

```dart
class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final FastSlidableController controller = FastSlidableController(this);

  @override
  void dispose() {
    controller.dispose(); // only if you created it
    super.dispose();
  }

  void _handleOpen() {
    controller.openEnd();
    // or controller.openStart();
  }

  void _handleClose() {
    controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return FastSlidable(
      controller: controller,
      endPane: FastSlidablePane(...),
      child: tile,
    );
  }
}
```

Dispose an external controller yourself. The widget only detaches listeners when the instance is replaced or the State is disposed; it never disposes a controller you passed in. If you omit it, the widget creates and disposes its own. Use `FastSlidable.of(context)` in the subtree.

---

## FastRefresh {#refresh}

Recommended pairing: vertical `FastRefresh` / `FastPagingList` + horizontal `FastSlidable`.

- Slidable registers drag recognizers on its own axis only
- `closeOnScroll` (default true) closes the pane when the nearest scrollable moves
- Sliding is locked—and the open pane closes—when `userOffsetNotifier` is true or a Header / Footer is not `inactive`
- **Same-axis is unsupported**: horizontal Refresh + horizontal Slidable has no gesture arbitration

Compose Slidable in `itemBuilder`. Do not add it to the `FastPagingList` API.

---

## Theme {#theme}

```dart
ThemeData(
  extensions: [FastSlidableTheme.light],
)
```

Resolution order: `resolve` overrides → `ThemeExtension` → `light` / `dark` by brightness. The theme covers default durations, curve, action spacing / radius, and fallback foreground color.
