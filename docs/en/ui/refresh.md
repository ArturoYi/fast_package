---
title: Refresh
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_refresh" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_refresh/</code>
</p>

## Overview {#overview}

`FastRefresh` ports EasyRefresh’s core physics and state machine: custom `ScrollPhysics` for friction / rebound / overscroll, and Header/Footer notifiers that drive

`inactive → drag → armed → ready → processing → processed → done`.

After release the list springs to the trigger offset, then the task runs. The default skin is Classic (rotating arrow + text + spinner).

| Topic | Notes |
| --- | --- |
| Entry | `FastRefresh(onRefresh, onLoad, child)` or `FastRefresh.builder` |
| Controller | `FastRefreshController`: `callRefresh` / `callLoad` / `finish*` / `resetFooter` |
| Results | `success` / `fail` / `noMore` |
| Default indicators | `FastClassicHeader` / `FastClassicFooter` |
| Custom | `FastBuilderHeader` / `FastBuilderFooter`, or listener / locator |
| Physics | bouncing (list moves) and clamping (list stays, indicator moves) |

::: tip
Do not nest another independently scrolling view inside `child` unless you give it its own physics, or use `FastRefresh.builder` and attach physics yourself. See the example app’s `RefreshExample` page.
:::

---

## Basic usage {#basic}

```dart
import 'package:fast_package/fast_package.dart';

final controller = FastRefreshController(
  controlFinishRefresh: true,
  controlFinishLoad: true,
);

FastRefresh(
  controller: controller,
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

Pass `null` for `onRefresh` / `onLoad` to disable that side.

You can also skip controller finish and `return FastRefreshResult.success` (or `fail` / `noMore`). A thrown callback becomes `fail` and is not rethrown.

---

## Widget constructor vs builder {#widget-vs-builder}

Same split as EasyRefresh: the default constructor injects physics into the subtree; `FastRefresh.builder` hands physics to you.

### Widget constructor {#widget-ctor}

```dart
FastRefresh(
  onRefresh: () async {},
  child: ListView(), // no physics argument needed
);
```

| | Notes |
| --- | --- |
| Pros | Zero boilerplate for a single list; child `ScrollView`s pick up refresh physics |
| Cons | Every scrollable in the subtree shares that physics; nested scroll can steal overscroll |
| Use when | One `ListView` / `GridView` / `CustomScrollView` |

### builder constructor {#builder-ctor}

```dart
FastRefresh.builder(
  onRefresh: () async {},
  childBuilder: (context, physics) {
    return CustomScrollView(
      physics: physics, // required, or pull-to-refresh never starts
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Title')),
        SliverList(delegate: SliverChildListDelegate.fixed([])),
      ],
    );
  },
);
```

| | Notes |
| --- | --- |
| Pros | You choose which scroll layer refreshes; nested / multi-list layouts stay isolated |
| Cons | Forgetting `physics: physics` leaves platform physics; refresh will not run |
| Use when | `NestedScrollView`, `PageView` + lists, or another scrollable outside the list |

Start with the widget constructor. Switch to builder when an inner list steals the gesture. Pair with `isNested: true` for NestedScrollView. The example app has `refresh_example/widget` and `refresh_example/builder`.

---

## State machine {#states}

```
inactive → drag → armed → ready → processing → processed → done → inactive
```

The Classic footer defaults to `infiniteOffset = 70`: load starts when the list is within 70px of the bottom. Set `infiniteOffset: null` for pull-and-release only.

A successful refresh with `resetAfterRefresh` (default `true`) clears footer `noMore`. Refresh and load are mutually exclusive unless `simultaneously` is `true`.

---

## More {#more}

- **`FastRefresh.builder`**: see [Widget constructor vs builder](#widget-vs-builder).
- **`refreshOnStart`**: trigger refresh after the first frame.
- **`FastHeaderLocator` / `FastFooterLocator`**: place the indicator inside the list (`position: locator`).
- **`clamping: true`**: the list does not overscroll; only the indicator moves.
- **Secondary floor**: `secondaryTriggerOffset` plus `openHeaderSecondary` / `closeHeaderSecondary`.

---

## Custom indicator {#custom}

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
