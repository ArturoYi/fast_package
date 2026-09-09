---
title: Refresh
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_refresh" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_refresh/</code>
</p>

<DocCredit module="refresh" />

## Overview {#overview}

`FastRefresh` uses custom `ScrollPhysics` for friction / rebound / overscroll, and Header/Footer notifiers that drive

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

The default constructor injects physics into the subtree; `FastRefresh.builder` hands physics to you.

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
Scaffold(
  appBar: AppBar(title: const Text('Title')),
  body: FastRefresh.builder(
    onRefresh: () async {},
    childBuilder: (context, physics) {
      return CustomScrollView(
        physics: physics, // required, or pull-to-refresh never starts
        slivers: [
          SliverList(delegate: SliverChildListDelegate.fixed([])),
        ],
      );
    },
  ),
);
```

Keep the AppBar outside `FastRefresh` so refresh starts at the list top. Do not put `SliverAppBar` in the default builder snippet; use Nested (`isNested: true`) or Locator for a collapsing bar.

| | Notes |
| --- | --- |
| Pros | You choose which scroll layer refreshes; nested / multi-list layouts stay isolated |
| Cons | Forgetting `physics: physics` leaves platform physics; refresh will not run |
| Use when | `NestedScrollView`, `PageView` + lists, or another scrollable outside the list |

Start with the widget constructor. Switch to builder when an inner list steals the gesture. Pair with `isNested: true` for NestedScrollView. The example hub has Widget, Builder, Nested, Locator, refreshOnStart, clamping, horizontal, and secondary.

---

## State machine {#states}

```
inactive → drag → armed → ready → processing → processed → done → inactive
```

The Classic footer defaults to `infiniteOffset = 70`: load starts when the list is within 70px of the bottom. Set `infiniteOffset: null` for pull-and-release only.

A successful refresh with `resetAfterRefresh` (default `true`) clears footer `noMore`. Refresh and load are mutually exclusive unless `simultaneously` is `true`.

---

## More {#more}

- **`FastRefresh.builder`**: see [Widget constructor vs builder](#widget-vs-builder). Example: `refresh_example/builder`.
- **`refreshOnStart`**: trigger refresh after the first frame. Example: `refresh_example/refresh_on_start`.
- **`FastHeaderLocator` / `FastFooterLocator`**: place the indicator inside the list (`position: locator`). Example: `refresh_example/locator`.
- **`clamping: true`**: the list does not overscroll; only the indicator moves. Example: `refresh_example/clamping`.
- **`isNested: true`**: pin an outer app bar and refresh the inner list. Example: `refresh_example/nested`.
- **Horizontal**: `ListView` / `PageView` with `scrollDirection: Axis.horizontal`. Example: `refresh_example/horizontal`. See [Horizontal](#horizontal).
- **Secondary floor**: keep pulling past the refresh trigger to open a second page. Example: `refresh_example/secondary`. See [Secondary floor](#secondary).

---

## Horizontal {#horizontal}

Switch the list to horizontal scroll. Classic Header / Footer move to the leading and trailing edges.

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

| Topic | Notes |
| --- | --- |
| `scrollDirection` | With `Axis.horizontal`, Header is on the left and Footer on the right (forward lists) |
| `triggerAxis` | Optional. `Axis.horizontal` responds only on that axis; `null` means no filter |
| `PageView` | Set footer `infiniteOffset: null`, or paging a page starts `onLoad` |
| `clipBehavior` | Use `Clip.none` when the indicator paints outside the viewport |

See `refresh_example/horizontal` for a page that toggles `ListView` and `PageView`.

---

## Secondary floor {#secondary}

Pull past the normal refresh trigger to open a near-full-screen second page. The state machine is already in the kernel; compose the page with `FastSecondaryBuilderHeader`.

```
inactive → drag → armed → …          normal refresh
                 ↘ secondaryArmed → secondaryReady → secondaryOpen
                                                      ↓
                                              secondaryClosing → inactive
```

| Parameter | Notes |
| --- | --- |
| `secondaryTriggerOffset` | Distance that opens the floor; must be greater than `triggerOffset` |
| `secondaryDimension` | Height when open; defaults to the viewport |
| `secondaryVelocity` | Snap-open speed after release; default 3000 |
| `secondaryCloseTriggerOffset` | How far to push back before closing; default 70 |

Do not combine `secondaryTriggerOffset` with `infiniteOffset` (the default Header has no infinite refresh; do not enable it on a secondary Header).

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
          // Second-floor page: screen height, opacity follows the gesture
          header.build(context, state),
        ],
      );
    },
  ),
  child: CustomScrollView(
    slivers: [
      // Sync SliverAppBar with listenable
      const FastHeaderLocator.sliver(),
      // list
    ],
  ),
);
```

Open / close:

- Gesture: pull past `secondaryTriggerOffset` and release
- Programmatic: `controller.openHeaderSecondary()` / `closeHeaderSecondary()`
- Back: while open, `PopScope(canPop: false)` should call `closeHeaderSecondary()`

`FastRefresh.clipBehavior` must be `Clip.none`, or the taller second-floor page is clipped. Full recipe: `refresh_example/secondary`.

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
