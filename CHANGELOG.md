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
