## 0.0.6

* Added `FastAnimatedList` / `FastReorderableList` / `FastAnimatedReorderableList`: implicit insert/remove, drag reorder, first-frame stagger
* Shared list ticker for stagger (no per-item `AnimationController`); large diffs snap after `animationBudget`
* `FastStagger` for Column / custom lists; `FastListDragHandle` for handle-triggered reorder
* `onReorder` matches `ReorderableListView`; vertical `FastRefresh` locks drag while pulling / processing
* Added `FastAnimatedListTheme` (`ThemeExtension`)
* Load-more appends keep scrolling smooth: FastRefresh no longer rebuilds ballistic when new items grow the list back in-range; FastAnimatedList snaps tail inserts while Refresh is active or the list is still moving
* FastAnimatedList + FastRefresh no longer rebuilds every tile when the finger goes down (`userOffset`); drag lock is checked at drag-start. FastSlidable does the same for swipe lock. Refresh demos return `noMore` after the last page
* Fixed handle-triggered reorder: hover used the shift `Transform` origin, so `FastListDragHandle` could not change order; the handle now also claims the gesture immediately so the parent `Scrollable` cannot steal a vertical drag
* Example: Animated List scenes now cover insert/remove (batch), drag, both, Refresh, Slidable, and Refresh+Slidable, each with List / Sliver / Column × list / grid
* Added `FastSlidable`: swipe to reveal actions, iOS-style full swipe, dismiss-to-delete, programmatic `FastSlidableController`
* Built-in motions: `behind` / `drawer` / `scroll`; vertical axis supported
* `FastSlidableGroup` keeps one open row per `groupTag`; `closeOnScroll` closes on list scroll
* Works with vertical `FastRefresh` / `FastPagingList`: refresh drag or processing locks sliding
* Added `FastRefresh.maybeOf` for optional ancestor lookup
* Added `FastSlidableTheme` (`ThemeExtension`)

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
