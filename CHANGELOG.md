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

* Added global Overlay Toast: `showToast` (optional `builder` for custom content)

## 0.0.7

* Added global Overlay Loading: `showLoading` (center only, barrier, no queue; optional `builder` for custom content)
* `showToast` / `showLoading` use a single entry; custom content goes through `builder` (removed `showCustomToast` / `showCustomLoading`)

## 0.0.6

* Added `FastRefresh`: EasyRefresh-aligned pull-to-refresh and load-more (custom physics, full indicator state machine, Classic header/footer, controller, `noMore`, builder / locator / refreshOnStart)
* Documented Widget constructor vs `FastRefresh.builder`; default builder keeps AppBar outside `FastRefresh`
* Example hub adds Nested, Locator, refreshOnStart, clamping, horizontal ListView/PageView, and Header secondary-floor pages
* Tests cover NestedScrollView + `isNested`, locator slivers, `refreshOnStart`, footer completion sync, horizontal scroll, and Header secondary open/close
* Documented horizontal axis (`triggerAxis`, PageView must disable footer infinite load) and the secondary-floor recipe
