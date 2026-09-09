---
title: Loading
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_loading" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_loading/</code>
</p>

<DocCredit module="loading" />

## Overview {#overview}

Global loading lives on the app-root overlay. Call `showLoading` **without** a `BuildContext`; they are not tied to the navigator stack. Placement is center-only. Only one loading is visible; a later call **replaces** the current overlay instead of queueing.

| Topic | Notes |
| --- | --- |
| Show API | `showLoading()`; pass `builder` for custom content |
| Host | Wrap `MaterialApp.builder` with `FastLoadingOverlay` |
| Position | Center only |
| Dismiss | Call `FastLoading.dismiss()` (or tap the barrier when enabled) |
| Back | Back navigation is blocked while visible; route-level lock needs the same `navigatorKey` |
| Theme | `FastLoadingTheme` (`ThemeExtension`) for the default panel and barrier |
| **Not provided** | Extra positions, FIFO queue, auto-dismiss, percent progress |

::: tip
Calls made before `FastLoadingOverlay` is mounted are stored as pending and do not throw. See the example app’s `LoadingExample` page for a full demo.
:::

---

## Setup {#setup}

When used with Toast, wrap Loading on the outside so its barrier sits above toasts:

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

MaterialApp(
  navigatorKey: rootNavigatorKey,
  builder: (context, child) {
    return FastLoadingOverlay(
      navigatorKey: rootNavigatorKey,
      child: FastToastOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  },
  // ...
);
```

If you only need Loading, wrap `FastLoadingOverlay` alone. `navigatorKey` must be the **same instance** as `MaterialApp.navigatorKey`: system back, AppBar back, iOS swipe-back, and `Navigator.maybePop` all go through the current route on that navigator. Without the key, a pushed route can still pop. Direct `Navigator.pop` is **not** blocked.

---

## Examples {#loading-example}

```dart
import 'package:fast_package/fast_package.dart';

showLoading();

showLoading(message: 'Loading...');

showLoading(
  message: 'Tap the barrier to close',
  config: FastLoadingConfig(barrierDismissible: true),
);

showLoading(
  builder: (context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 12),
        Text('Custom content'),
      ],
    );
  },
);

FastLoading.dismiss();
FastLoading.dismissNow();
```

`builder` inserts your widget as loading **content**. The host still owns centering, fade, and the barrier, and does **not** wrap default panel chrome. The callback receives the overlay-tree `BuildContext`, so `Theme.of` works; do not capture a disposed page `BuildContext`. When `builder` is set, `message` is ignored.

---

## Theme setup {#loading-theme-setup}

`FastLoadingTheme` styles the default panel (background, spinner, text, shadow) and the barrier color:

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [FastLoadingTheme.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [FastLoadingTheme.dark],
  ),
  builder: (context, child) {
    return FastLoadingOverlay(child: child ?? const SizedBox.shrink());
  },
);
```

Resolution order:

1. A `FastLoadingTheme` registered on `ThemeData`
2. Fallback to `FastLoadingTheme.light` / `dark` from `ThemeData.brightness`

---

## API {#loading-api}

### `showLoading`

```dart
void showLoading({
  String? message,
  WidgetBuilder? builder,
  FastLoadingConfig? config,
});
```

### `FastLoading`

| Member | Notes |
| --- | --- |
| `isShowing` | Whether a loading overlay is on screen |
| `dismiss()` | Exit the current overlay with animation; clears pending when idle |
| `dismissNow()` | Remove the current overlay immediately and drop pending |

### `FastLoadingConfig`

| Parameter | Default | Notes |
| --- | --- | --- |
| `barrierDismissible` | `false` | Tap the barrier to dismiss |
| `lockPop` | `true` | Block back navigation while visible |

---

## Non-goals {#non-goals}

- No top / bottom placement and no compositing-layer keyboard shift
- No queue and no auto-dismiss duration
- No Toast coordination and no percent / progress loading
