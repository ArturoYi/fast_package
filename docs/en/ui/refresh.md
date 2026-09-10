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
| Paging | `FastPagingList` (`fetchPage`) or a `FastPaging` subclass |
| Default indicators | `FastClassicHeader` / `FastClassicFooter`; optional `FastMaterial*` |
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

Start with the widget constructor. Switch to builder when an inner list steals the gesture. Pair with `isNested: true` for NestedScrollView. The example hub has Widget, Builder, Nested, Locator, refreshOnStart, Paging, clamping, horizontal, and secondary.

---

## State machine {#states}

```
inactive → drag → armed → ready → processing → processed → done → inactive
```

The Classic footer defaults to `infiniteOffset = 70`: load starts when the list is within 70px of the bottom. Set `infiniteOffset: null` for pull-and-release only.

A **successful** refresh with `resetAfterRefresh` (default `true`) clears footer `noMore`. Fail, thrown errors, and `noMore` do not. When `controlFinishRefresh` is true, reset happens on `finishRefresh(success)` only.

After `FastRefresh` is disposed or its controller is replaced, `callRefresh` / `finishRefresh` on the old controller are no-ops.

Refresh and load are mutually exclusive unless `simultaneously` is `true`.

---

## More {#more}

Same order as the example hub:

- **`FastRefresh.builder`**: see [Widget constructor vs builder](#widget-vs-builder). Example: `refresh_example/builder`.
- **`isNested: true`**: pin an outer app bar and refresh the inner list. Example: `refresh_example/nested`.
- **`FastHeaderLocator` / `FastFooterLocator`**: place the indicator inside the list (`position: locator`). Example: `refresh_example/locator`.
- **`refreshOnStart`**: trigger refresh after the first frame. Example: `refresh_example/refresh_on_start`.
- **`FastPaging` / `FastPagingList`**: page / total / empty state wired to refresh and load. `FastPagingList` only needs `fetchPage` + `itemBuilder`. Example: `refresh_example/paging`. See [Paging](#paging).
- **`clamping: true`**: the list does not overscroll; only the indicator moves. Example: `refresh_example/clamping`.
- **`FastMaterialHeader` / `FastMaterialFooter`**: system-style crescent spinner. Example: `refresh_example/material`. See [Material](#material).
- **`FastRefreshTheme`**: Classic copy and Material colors via `ThemeExtension`. See [Theme](#theme).
- **Horizontal**: `ListView` / `PageView` with `scrollDirection: Axis.horizontal`. Example: `refresh_example/horizontal`. See [Horizontal](#horizontal).
- **Secondary floor**: keep pulling past the refresh trigger to open a second page. Example: `refresh_example/secondary`. See [Secondary floor](#secondary).

---

## Paging {#paging}

For everyday lists use `FastPagingList<T>` — no subclass:

```dart
FastPagingList<String>(
  refreshOnStart: true,
  fetchPage: (page) async {
    final res = await api.list(page);
    return FastPagingPage(
      items: res.items,
      page: res.page,
      total: res.total,
    );
  },
  itemBuilder: (context, index, item) => ListTile(title: Text(item)),
)
```

`isNoMore`: explicit `hasMore` → `total` / `page`+`totalPage` → last successful page has empty `items`. Keep subclassing `FastPaging` for complex data shapes.

`FastPaging<DataType, ItemType>` matches EasyRefresh's companion `EasyPaging`: subclasses keep data and page fields; the base class wires refresh / load, empty state, and `noMore` to `FastRefresh`.

`isNoMore` uses `total` first (`count >= total`), otherwise `page >= totalPage`. If `onLoad` returns no result, the base class emits `noMore` or `success` from that flag. When the first page already contains everything, refresh finishes by locking the footer as `noMore`.

```dart
class CustomPaging extends FastPaging<List<String>, String> {
  const CustomPaging({super.key, super.refreshOnStart = true, super.itemBuilder});

  @override
  FastPagingState<List<String>, String, CustomPaging> createState() =>
      _CustomPagingState();
}

class _CustomPagingState
    extends FastPagingState<List<String>, String, CustomPaging> {
  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) => data![index];

  @override
  int? page;

  @override
  int? total;

  @override
  int? totalPage;

  @override
  Widget buildItem(BuildContext context, int index, String item) {
    return buildItemByBuilder(context, index, item);
  }

  @override
  Future<FastRefreshResult?> onRefresh() async {
    final first = await fetchPage(1);
    setState(() {
      data = first.items;
      page = first.page;
      total = first.total;
    });
    return null;
  }

  @override
  Future<FastRefreshResult?> onLoad() async {
    final next = await fetchPage(page! + 1);
    setState(() {
      data = <String>[...data!, ...next.items];
      page = next.page;
      total = next.total;
    });
    return null;
  }
}
```

| Topic | Notes |
| --- | --- |
| Default | `useDefaultPhysics: false` uses `FastRefresh.builder` and attaches physics to the inner `CustomScrollView` |
| Widget constructor | `useDefaultPhysics: true` for a single list with no nested scroll |
| Empty | `emptyWidgetBuilder` or override `buildEmptyWidget` when `isEmpty` |
| On start | `refreshOnStart` + `refreshOnStartWidgetBuilder` |
| Locator | Locator slivers are inserted when Header / Footer `position` is `locator` |

See the example app’s `refresh_example/paging` (45 items, 10 per page, empty-state and widget-constructor toggles).

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

## Material {#material}

The default skin is still Classic. For the system crescent spinner, use `FastMaterialHeader` (default `clamping: true`). `FastMaterialFooter` uses `CircularProgressIndicator` and still infinite-loads (`infiniteOffset: 70`, `clamping: false` — clamping cannot combine with infinite load).

```dart
FastRefresh(
  header: const FastMaterialHeader(),
  footer: const FastMaterialFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
);
```

---

## Theme {#theme}

`FastRefreshTheme` is a `ThemeExtension`. Classic copy / styles and Material colors resolve as widget args → theme → light/dark English defaults. It does not change trigger distance or springs.

```dart
ThemeData(
  extensions: [
    FastRefreshTheme(
      headerTexts: FastRefreshIndicatorTexts(
        dragText: 'Pull to refresh',
        armedText: 'Release ready',
        readyText: 'Refreshing...',
        processingText: 'Refreshing...',
        processedText: 'Succeeded',
        noMoreText: 'No more',
        failedText: 'Failed',
        messageText: 'Last updated at %T',
      ),
      footerTexts: FastRefreshIndicatorTexts.footerEnglish,
      indicatorColor: Colors.blue,
    ),
  ],
)
```

Without a registered theme, Classic keeps its English defaults (`Pull to refresh`).

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
