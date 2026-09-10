---
title: Shimmer
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_shimmer" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_shimmer/</code>
</p>

<DocCredit module="shimmer" />

## Overview {#overview}

The `FastShimmer` family provides **hand-crafted loading skeletons** and **decorative highlight sweeps**. Compose skeletons with `FastShimmerBox` / `FastShimmerCircle` / `FastShimmerText` / `FastShimmerList`; sweep a thin white beam across real text / icons / thumbs with `FastShimmerHighlight`. `FastShimmerScope` drives one shared `AnimationController` plus `ShaderMask` so every descendant in that scope stays in phase.

| Topic | Notes |
| --- | --- |
| Loading entry | `FastShimmer(isLoading, skeleton, child)` |
| Sync animation | `FastShimmerScope` (auto-wrapped by `FastShimmer` / `FastShimmerHighlight` when no ancestor exists) |
| Placeholders | `Box` / `Circle` / `Text` (skeleton bars) / `List` |
| Decorative sweep | `FastShimmerHighlight` (thin beam) / `FastShimmerSlideUnlock` (draggable; `area` whole bar / `label` text only) |
| Theming | `FastShimmerTheme` (`ThemeExtension`) + `FastShimmerDirection` |
| **Not provided** | Auto-inferring skeleton shapes from `child`; dragging does not fade the label |

::: tip
Pixels under the sweep must be **opaque** (package placeholders default to white; real text should use a solid glyph color — the text factory forces white). Visible colors come from the theme, not the child’s own `color`. See the example app’s `ShimmerExample` hub (skeleton / highlight / slide unlock).
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

## Decorative highlight {#shimmer-highlight}

`FastShimmerText` is a **paragraph skeleton**. To shine real glyphs, wrap an opaque `Text` / `Icon` with `FastShimmerHighlight`:

```dart
FastShimmerHighlight.text(
  'Slide to unlock',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0x66FFFFFF), // used as baseColor when omitted
  ),
  highlightColor: Colors.white,
);
```

Default motion is a thin white band: about **3 s** left → right, then a **~1.8 s** pause before the next loop. Glyph color stays put — it does not fade. `ShaderMask` only tints opaque pixels of [child]; keep the track / card background outside the scope so it stays still.

Any opaque child works:

```dart
FastShimmerHighlight(
  baseColor: const Color(0xFF9E9E9E),
  highlightColor: Colors.white,
  child: const Icon(Icons.chevron_right, color: Colors.white),
);
```

Draggable slide-to-unlock: a slanted soft sheen sweeps left → right in about **3 s**, then pauses about **1.8 s** before looping. Both wrap styles share that timing — `area` sweeps the metal capsule (centered label and thumb sit on top), `label` sweeps only the centered hint glyphs (track and thumb stay still). Keep the page / card background outside the control so it does not move; the label does not fade while dragging; `resetOnUnlock` returns the thumb after unlock:

```dart
FastShimmerSlideUnlock(
  label: 'Slide to unlock',
  highlight: FastShimmerSlideUnlockHighlight.area, // or .label
  successLabel: 'Unlocked',
  resetOnUnlock: true,
  onUnlocked: _unlock,
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
  Duration pauseDuration = Duration.zero,
  FastShimmerSweep sweep = FastShimmerSweep.wash,
  double bandWidth = 0.18,
  double sheenRotation = FastShimmerScope.beamSheenRotation,
});
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | yes | Skeleton subtree under the shimmer mask |
| `duration` | `Duration` | no | **Sweep** length (not including pause); 1500 ms for skeletons |
| `pauseDuration` | `Duration` | no | Hold after the sweep; default `0` (continuous skeleton wash) |
| `sweep` | `FastShimmerSweep` | no | `wash` for skeletons; `beam` for a slanted soft sheen |
| `bandWidth` | `double` | no | Beam width as a fraction of the sweep axis; `beam` only; wider is softer |
| `sheenRotation` | `double` | no | Beam tilt in radians; default about -0.45; use `0` for a straight text swipe |

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

This is a paragraph **skeleton**, not a sweep on real glyphs. Use `FastShimmerHighlight` for real text.

---

#### `FastShimmerHighlight` {#fast-shimmer-highlight}

```dart
const FastShimmerHighlight({
  required Widget child,
  Duration? duration,
  Duration? pauseDuration,
  double? bandWidth,
  Color? baseColor,
  Color? highlightColor,
  FastShimmerDirection? direction,
});

factory FastShimmerHighlight.text(
  String data, {
  TextStyle? style,
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
  Duration? duration,
  Duration? pauseDuration,
  double? bandWidth,
  Color? baseColor,
  Color? highlightColor,
  FastShimmerDirection? direction,
});
```

| Parameter | Description |
| --- | --- |
| `child` | Opaque content that receives the sweep (typically solid `Text` / `Icon` / thumb) |
| `duration` | Sweep length; default **3 s**; ignored if an ancestor Scope exists |
| `pauseDuration` | Hold after the sweep; default **1.8 s** |
| `bandWidth` | Beam width fraction; default `0.18` |
| `baseColor` / `highlightColor` / `direction` | Theme overrides only when this widget creates its own Scope |

The `text` factory forces an opaque white glyph color so `ShaderMask` can paint. When `baseColor` is omitted, `style.color` becomes the shimmer base. If an ancestor `FastShimmerScope` exists, a second scope is **not** wrapped and color / timing overrides do not apply. A locally created scope uses `FastShimmerSweep.beam`.

---

#### `FastShimmerSlideUnlock` {#fast-shimmer-slide-unlock}

```dart
const FastShimmerSlideUnlock({
  String label = '滑动解锁',
  String? successLabel,
  VoidCallback? onUnlocked,
  double height = 60,
  double thumbSize = 52,
  double threshold = 0.85,
  bool enabled = true,
  bool resetOnUnlock = true,
  FastShimmerSlideUnlockHighlight highlight =
      FastShimmerSlideUnlockHighlight.label,
  Color? trackColor,
  Color thumbColor = Colors.white,
  IconData? thumbIcon,
  IconData? successIcon,
  TextStyle? labelStyle,
  Color? baseColor,
  Color? highlightColor,
  Duration? duration,
  Duration? pauseDuration,
});
```

| Parameter | Description |
| --- | --- |
| `label` | Hint text (does not fade while dragging) |
| `successLabel` | Optional post-unlock label |
| `onUnlocked` | Called once after the slide crosses `threshold` and settles |
| `threshold` | Required progress in `(0, 1]`; default `0.85` |
| `enabled` | When `false`, the thumb cannot be dragged |
| `resetOnUnlock` | Whether the thumb returns after the callback (default `true`) |
| `highlight` | `area` sweeps the capsule; `label` sweeps only the text (default) |
| `duration` / `pauseDuration` | Beam sweep / pause; default 3 s / 1.8 s; shared by both wrap styles |

The beam travels the slider width. `area` puts an opaque capsule in the mask (metal sheen) with the label and thumb on top; `label` keeps only the glyphs opaque, with the track and thumb outside the mask. In RTL the thumb travels right → left.

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

### Highlight text {#shimmer-text-recipe}

```dart
FastShimmerHighlight.text(
  'FAST PACKAGE',
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Color(0xFFC9A227),
  ),
  highlightColor: const Color(0xFFFFF4C2),
);
```

### Slide to unlock {#shimmer-slide-unlock-recipe}

```dart
FastShimmerSlideUnlock(
  label: 'Slide to unlock',
  highlight: FastShimmerSlideUnlockHighlight.area,
  successLabel: 'Unlocked',
  resetOnUnlock: true,
  onUnlocked: () {
    // Business after unlock
  },
);
```

See `shimmer_example/slide_hint` in the example app.

---

## Notes {#shimmer-notes}

- **Hand-crafted only**: `skeleton` is required; there is no auto-detect / shape detector.
- **Two text widgets**: `FastShimmerText` = skeleton bars; `FastShimmerHighlight` = thin beam on real glyphs.
- **wash vs beam**: Skeletons default to a continuous `wash`; decorative highlight defaults to a slanted soft `beam` (3 s sweep + 1.8 s pause).
- **One Scope**: Prefer one scope per screen or loading subtree; nesting is allowed but usually unnecessary. `FastShimmerHighlight` inside a loading scope reuses the ancestor sweep; local color / timing overrides do not apply.
- **Opaque pixels**: `BlendMode.srcIn` uses the child as a mask; visible color comes from the shimmer gradient. Keep backgrounds outside the scope. Text highlights need an **opaque** base (translucent white on white glyphs cancels the beam). Text color does not fade with the animation.
- **Accessibility**: Honors `MediaQuery.disableAnimations`; loading is announced as `Loading` by `FastShimmer`.
- **Performance**: The sweep runs at the Scope layer; placeholders are not rebuilt every animation frame.
