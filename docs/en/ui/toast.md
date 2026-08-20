---
title: Toast
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_toast" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_toast/</code>
</p>

## Overview {#overview}

Global toasts live on the app-root overlay. Call `showToast` / `showCustomToast` **without** a `BuildContext`; they are not tied to the navigator stack. Only one toast is visible at a time; extras wait in a FIFO queue.

| Topic | Notes |
| --- | --- |
| Show API | `showToast(message)` / `showCustomToast(widget)` |
| Host | Wrap `MaterialApp.builder` with `FastToastOverlay` |
| Queue | Single slot, FIFO; pending cap 5, drop-oldest |
| Theme | `FastToastTheme` (`ThemeExtension`) for the text panel only |
| **Not provided** | `success` / `error` / `info` types, priority interrupt, progress toasts |

::: tip
Calls made before `FastToastOverlay` is mounted enqueue without throwing. See the example app’s `ToastExample` page for a full demo.
:::

---

## Setup {#setup}

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

MaterialApp(
  builder: (context, child) {
    return FastToastOverlay(
      child: child ?? const SizedBox.shrink(),
    );
  },
  // ...
);
```

---

## Examples {#toast-example}

```dart
import 'package:fast_package/fast_package.dart';

showToast('Saved');

showToast(
  'Network error',
  config: FastToastConfig(
    duration: Duration(seconds: 3),
    position: FastToastPosition.bottom,
    dismissible: true,
  ),
);

showCustomToast(
  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: Colors.green),
      SizedBox(width: 8),
      Text('Custom content'),
    ],
  ),
);

FastToast.dismiss();
FastToast.dismissAll();
```

`showCustomToast` inserts your widget as toast **content**. The host still owns queue, position, duration, and motion, and does **not** wrap default panel chrome. The widget is built under the overlay tree (`Builder` / `Theme.of` work); do not capture a disposed page `BuildContext`.

---

## Theme setup {#toast-theme-setup}

`FastToastTheme` styles the default `showToast` text panel only:

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [FastToastTheme.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [FastToastTheme.dark],
  ),
  builder: (context, child) {
    return FastToastOverlay(child: child ?? const SizedBox.shrink());
  },
);
```

Resolution order:

1. A `FastToastTheme` registered on `ThemeData`
2. Fallback to `FastToastTheme.light` / `dark` from `ThemeData.brightness`

---

## API {#toast-api}

### `showToast` / `showCustomToast`

```dart
void showToast(String message, {FastToastConfig? config});

void showCustomToast(Widget toast, {FastToastConfig? config});
```

### `FastToast`

| Member | Notes |
| --- | --- |
| `isShowing` | Whether a toast is on screen |
| `pendingCount` | Pending items, excluding the visible toast |
| `dismiss()` | Exit the current toast, then show the next; no-op when idle |
| `dismissAll()` | Clear the queue and remove the current toast immediately |

### `FastToastConfig`

| Parameter | Default | Notes |
| --- | --- | --- |
| `duration` | `2000ms` | Time on screen before exit animation |
| `position` | `FastToastPosition.center` | `top` / `center` / `bottom` |
| `dismissible` | `false` | Tap content to dismiss |

---

## Non-goals {#non-goals}

- No `FastToastType` and no `success` / `error` / `info` helpers
- No Loading coordination and no high-priority interrupt
- No animation enum and no progress toast
