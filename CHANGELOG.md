## 0.0.6

* Added `FastAnimatedList` / `FastSliverAnimatedList`: insert and remove animate from `items` + stable `itemId` (no manual insert/remove calls)
* Added `FastReorderableList` / `FastSliverReorderableList` and `FastAnimatedReorderableList` / `FastSliverAnimatedReorderableList` when drag reorder is needed alone or together with insert/remove
* First-frame stagger uses one shared list ticker (no per-item `AnimationController`); diffs larger than `animationBudget` snap into place
* `FastStagger` covers Column and custom lists (`list` / `grid` / `synchronized` / `none`); later items that scroll into view do not replay the entrance
* Drag is long-press by default, or `FastListDragTrigger.handle` + `FastListDragHandle`; `onReorder` matches `ReorderableListView`
* Added `FastAnimatedListTheme` (`ThemeExtension`)
* Vertical `FastRefresh` locks reorder and `FastSlidable` while pulling or processing; the lock is read at drag start, so pointer-down does not rebuild every tile
* Load-more stays smooth: `FastRefresh` no longer retargets the ballistic simulation once new items bring the list back in range; `FastAnimatedList` snaps tail inserts while Refresh is active or the list is still moving
* Fixed handle reorder: the drag origin no longer follows the shift `Transform`, and the handle claims the gesture immediately so the parent `Scrollable` cannot steal a vertical drag
* Added `FastSlidable`: swipe to reveal actions, full swipe, dismiss-to-delete, and programmatic `FastSlidableController`
* Built-in motions: `behind` / `drawer` / `scroll`; horizontal and vertical axes
* `FastSlidableGroup` keeps one open row per `groupTag`; `closeOnScroll` closes the open row when the list scrolls
* Dismiss and dismissing full swipe require a `key` on `FastSlidable`; releasing past `FastSlidableFullSwipe.threshold` now schedules a frame, so the row dismisses without waiting for a later tap
* Added `FastSlidableTheme` (`ThemeExtension`)
* Added `FastRefresh.maybeOf` for optional ancestor lookup
* `FastPagingState.replaceData` replaces loaded data and rebuilds after a local edit such as swipe-delete
* `FastRefresh` indicator listeners are deferred out of layout, so a header or footer `setState` during layout no longer hits "Build scheduled during frame"
* `FastShimmerScope` holds the gradient through `pauseDuration` without a `ShaderMask` saveLayer on every paused frame, and keeps the skeleton behind a `RepaintBoundary`
* `FastShimmerSlideUnlock` moves the thumb with a transform and pauses the beam while dragging, so drag frames do not rebuild the `ShaderMask`
* Loading overlay blocks route pop on the declared SDK range (Flutter 3.19+)
* Docs (Chinese and English) cover Animated List and Slidable; the docs site embeds the live Flutter web demo
* Example: Animated List scenes cover insert/remove (including batch), drag, both, Refresh, Slidable, and Refresh+Slidable, each with List / Sliver / Column × list / grid; Slidable scenes cover basic, dismiss, programmatic, vertical, and Refresh
* Tests cover list diff / stagger / reorder, slidable (including full-swipe dismiss), refresh layout notify, and slide-unlock drag

# 0.0.1

* TODO: Describe initial release.
* Added

* fast_debounce
* fast_throttle
* fast_rate_limit
* fast_extension

## 0.0.2

* Added new extensions

## 0.0.3

* Added new features
- cover_size
* Fixed bugs

## 0.0.4

* Added shimmer UI component
* Docs migrated to VitePress site（<https://arturoyi.github.io/fast_package/>）

## 0.0.5

* Overlay: `showToast` / `showLoading` (center, barrier, no queue); single entry, custom content via `builder` (removed `showCustomToast` / `showCustomLoading`)
* Added `FastRefresh`: EasyRefresh-aligned pull-to-refresh and load-more (custom physics, full indicator state machine, Classic header/footer, controller, `noMore`, builder / locator / `refreshOnStart`)
* Documented Widget constructor vs `FastRefresh.builder`; default builder keeps AppBar outside `FastRefresh`
* `FastRefresh` unbinds its controller on dispose / replacement; later `callRefresh` / `finishRefresh` are no-ops
* `resetAfterRefresh` clears footer `noMore` only after a successful refresh (`finishRefresh(success)` when completion is controlled)
* Added `FastRefreshTheme` (`ThemeExtension`) for Classic copy and Material colors
* Added `FastMaterialHeader` / `FastMaterialFooter` (SDK progress indicators; default skin stays Classic)
* Added `FastPaging`: EasyPaging-aligned pagination on top of FastRefresh (`page` / `total` / empty / `noMore`)
* Added `FastPagingList<T>` + `FastPagingPage<T>`: `fetchPage` + `itemBuilder` without subclassing `FastPaging`
* Added `FastShimmerHighlight`: thin beam on real text / icons / any opaque child (`ShaderMask`, not skeleton bars)
* `FastShimmerScope` gains `sweep` (`wash` / `beam`), `pauseDuration`, and `bandWidth`
* Highlight defaults: 3 s left-to-right beam, 1.8 s pause, highlight only on opaque glyphs (background stays still)
* Added `FastShimmerSlideUnlock`: draggable slider; `highlight` is `area` (slanted soft sheen on the metal capsule) or `label` (centered text only); both use the same 3 s sweep + 1.8 s pause; `resetOnUnlock`; label does not fade while dragging
* Example hub adds Nested, Locator, refreshOnStart, clamping, horizontal ListView/PageView, Header secondary-floor, Paging (`FastPagingList`), Material, Highlight, and Slide unlock pages
* Tests cover NestedScrollView + `isNested`, locator slivers, `refreshOnStart`, footer completion, horizontal scroll, Header secondary, controller unbind, success-only reset, theme, Material, FastPaging / FastPagingList, highlight beam timing, and unlock reset
* Documented horizontal axis (`triggerAxis`, PageView must disable footer infinite load), secondary-floor, FastPaging, and decorative shimmer recipes in Chinese and English
