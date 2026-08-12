---
title: Shimmer Skeletons
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_shimmer" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_shimmer/</code>
</p>

## Overview {#overview}

The `FastShimmer` family provides **hand-crafted loading skeletons** with a synchronized highlight sweep. Compose layouts with `FastShimmerBox` / `FastShimmerCircle` / `FastShimmerText` / `FastShimmerList`, and let `FastShimmerScope` drive one shared `AnimationController` plus `ShaderMask` so every descendant stays in phase.

| Topic | Notes |
| --- | --- |
| Entry point | `FastShimmer(isLoading, skeleton, child)` |
| Sync animation | `FastShimmerScope` (auto-wrapped by `FastShimmer` when no ancestor scope exists) |
| Placeholders | `Box` / `Circle` / `Text` / `List` |
| Theming | `FastShimmerTheme` (`ThemeExtension`) + `FastShimmerDirection` |
| **Not provided** | Auto-inferring skeleton shapes from `child` |

::: tip
Skeleton children must be **opaque** (package placeholders default to white) so the `ShaderMask` gradient is visible. See the example app’s `ShimmerExample` page for a full demo.
:::

---

## Examples {#shimmer-example}

Loading switch (recommended entry):

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

FastShimmer(
  isLoading: _loading,
  skeleton: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FastShimmerBox(width: double.infinity, height: 180),
      SizedBox(height: 12),
      Row(
        children: [
          FastShimmerCircle(diameter: 48),
          SizedBox(width: 12),
          FastShimmerText(lines: 2, width: 160),
        ],
      ),
    ],
  ),
  child: MyRealContent(),
);
```

Skeleton only, with an explicit scope:

```dart
FastShimmerScope(
  child: Column(
    children: [
      FastShimmerBox(width: double.infinity, height: 180),
      SizedBox(height: 12),
      FastShimmerCircle(diameter: 48),
      FastShimmerText(lines: 2, width: 160),
    ],
  ),
);
```

---

## Theme setup {#shimmer-theme-setup}

Register on `ThemeData.extensions` for app-wide base/highlight colors and direction (cycle length can still be overridden via Scope / `FastShimmer.duration`):

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [FastShimmerTheme.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [FastShimmerTheme.dark],
  ),
  // ...
);
```

Resolution order:

1. Explicit widget overrides (e.g. standalone `baseColor`)
2. `FastShimmerTheme` on `ThemeData`
3. Fallback to `FastShimmerTheme.light` / `dark` from `ThemeData.brightness`

---

## API reference {#shimmer-api}

---

#### `FastShimmer` {#fast-shimmer}

```dart
const FastShimmer({
  required Widget child,
  required bool isLoading,
  required Widget skeleton,
  Duration duration = const Duration(milliseconds: 1500),
});
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | yes | Real content when `isLoading` is `false` |
| `isLoading` | `bool` | yes | `true` → `skeleton`; `false` → `child` |
| `skeleton` | `Widget` | yes | Hand-built skeleton; **not** inferred from `child` |
| `duration` | `Duration` | no | Cycle length when auto-creating a Scope; ignored if an ancestor Scope exists |

While loading, Semantics use label `Loading` with `excludeSemantics`. If an ancestor `FastShimmerScope` already exists, a second scope is **not** wrapped (avoids double `ShaderMask`).

---

#### `FastShimmerScope` {#fast-shimmer-scope}

```dart
const FastShimmerScope({
  required Widget child,
  Duration duration = const Duration(milliseconds: 1500),
});
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | yes | Skeleton subtree under the shimmer mask |
| `duration` | `Duration` | no | One full highlight cycle; default 1500 ms |

Static helpers:

| Method | Description |
| --- | --- |
| `of(context)` | Nearest scope animation value `0.0`–`1.0`; `0.5` if none (subscribes) |
| `maybeOf(context)` | Animation value or `null` (subscribes when found) |
| `hasScope(context)` | Whether an ancestor Scope exists **without** per-frame subscription |

When `MediaQuery.disableAnimations` is `true`, the controller stops and freezes at `0.5`. `AnimatedBuilder` caches `child`, so placeholders are not rebuilt every tick.

---

#### `FastShimmerTheme` {#fast-shimmer-theme}

```dart
const FastShimmerTheme({
  required Color baseColor,
  required Color highlightColor,
  required Duration duration,
  required FastShimmerDirection direction,
});
```

| Member | Description |
| --- | --- |
| `baseColor` | Background color |
| `highlightColor` | Traveling highlight |
| `duration` | Theme cycle (align with Scope `duration` for a consistent feel) |
| `direction` | Highlight travel direction |
| `light` / `dark` | Built-in defaults |
| `of(context)` | Extension lookup; may be `null` |
| `resolve(context, {…})` | Effective theme with optional field overrides |
| `copyWith` / `lerp` | Standard `ThemeExtension` behavior; `direction` switches at `t == 0.5` |

Defaults (summary):

| Theme | `baseColor` | `highlightColor` | `duration` | `direction` |
| --- | --- | --- | --- | --- |
| `light` | `#E0E0E0` | `#F5F5F5` | 1500 ms | `leftToRight` |
| `dark` | `#2C2C2C` | `#3D3D3D` | 1500 ms | `leftToRight` |

---

#### `FastShimmerDirection` {#fast-shimmer-direction}

| Value | Highlight travel |
| --- | --- |
| `leftToRight` | Left → right |
| `rightToLeft` | Right → left |
| `topToBottom` | Top → bottom |
| `bottomToTop` | Bottom → top |
| `diagonal` | Top-left → bottom-right |

`toGradient({colors, stops})` builds a `LinearGradient` for that axis (Scope shifts `stops` each frame).

---

#### `FastShimmerBox` {#fast-shimmer-box}

```dart
const FastShimmerBox({
  required double width,
  required double height,
  BorderRadius borderRadius = BorderRadius.zero,
  Color? baseColor,
  Color? highlightColor,
  FastShimmerDirection? direction,
});
```

| Parameter | Description |
| --- | --- |
| `width` / `height` | Rectangle size (logical pixels) |
| `borderRadius` | Corners; sharp by default |
| `baseColor` | Overrides base color in **standalone** mode only |
| `highlightColor` / `direction` | Reserved for API consistency; unused inside a Scope |

Inside a Scope the fill is white; without a Scope it uses `baseColor` or the theme base (static).

---

#### `FastShimmerCircle` {#fast-shimmer-circle}

```dart
const FastShimmerCircle({
  required double diameter,
  Color? baseColor,
  Color? highlightColor,
  FastShimmerDirection? direction,
});
```

| Parameter | Description |
| --- | --- |
| `diameter` | Circle diameter (logical pixels) |
| `baseColor`, etc. | Same standalone / Scope fill rules as `FastShimmerBox` |

---

#### `FastShimmerText` {#fast-shimmer-text}

```dart
const FastShimmerText({
  int lines = 3,
  double lineHeight = 12.0,
  double lineSpacing = 6.0,
  double lastLineWidthFraction = 0.6,
  double width = 200.0,
  Color? baseColor,
  Color? highlightColor,
  FastShimmerDirection? direction,
});
```

| Parameter | Description |
| --- | --- |
| `lines` | Number of bars; at least 1 |
| `lineHeight` / `lineSpacing` | Bar height and gap |
| `width` | Full width of non-last lines |
| `lastLineWidthFraction` | Last line as a fraction of `width`, range `(0, 1]` |

---

#### `FastShimmerList` {#fast-shimmer-list}

```dart
const FastShimmerList({
  required int itemCount,
  Widget Function(int index)? itemBuilder,
  double separatorHeight = 12.0,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  bool shrinkWrap = true,
  ScrollPhysics? physics = const NeverScrollableScrollPhysics(),
});
```

| Parameter | Description |
| --- | --- |
| `itemCount` | Row count; non-negative |
| `itemBuilder` | Custom row; default is avatar circle + two text lines |
| `separatorHeight` | Gap between rows |
| `padding` / `shrinkWrap` / `physics` | List layout; non-scrollable by default for nesting |

Wrap with `FastShimmerScope` (or `FastShimmer`) so rows share one highlight.

---

## Recipes {#shimmer-recipes}

### List skeleton {#shimmer-list-recipe}

```dart
FastShimmer(
  isLoading: _loading,
  skeleton: FastShimmerList(
    itemCount: 5,
    itemBuilder: (index) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          FastShimmerCircle(diameter: 40),
          SizedBox(width: 12),
          FastShimmerText(lines: 2, width: 180),
        ],
      ),
    ),
  ),
  child: RealFeedList(),
);
```

### Local direction / color override {#shimmer-local-theme}

Inject `FastShimmerTheme` with an inner `Theme` for a preview region:

```dart
Theme(
  data: Theme.of(context).copyWith(
    extensions: [
      FastShimmerTheme.light.copyWith(
        direction: FastShimmerDirection.diagonal,
        highlightColor: const Color(0xFFFFFFFF),
      ),
    ],
  ),
  child: FastShimmerScope(
    child: FastShimmerBox(width: 200, height: 24),
  ),
);
```

### Standalone static placeholders {#shimmer-standalone}

Without a Scope, placeholders still render (theme base color) but without motion—useful for layout debugging or when animation is not needed yet.

---

## Notes {#shimmer-notes}

- **Hand-crafted only**: `skeleton` is required; there is no auto-detect / shape detector.
- **One Scope**: Prefer one scope per screen or loading subtree; nesting is allowed but usually unnecessary.
- **Accessibility**: Honors `MediaQuery.disableAnimations`; loading is announced as `Loading` by `FastShimmer`.
- **Performance**: The sweep runs at the Scope layer; placeholders are not rebuilt every animation frame.
