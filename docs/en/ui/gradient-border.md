---
title: Gradient Borders
outline: [2, 3]
---

## Overview {#overview}

`GradientBoxBorders` is a custom `BoxBorder` for painting a **gradient stroke** on `BoxDecoration.border` (instead of a solid `Border.all`). It supports rectangles (with optional `borderRadius`) and `BoxShape.circle`. Colors come from any Flutter `Gradient` (e.g. `LinearGradient`).

| Topic | Notes |
| --- | --- |
| Where to use | `BoxDecoration(border: GradientBoxBorders(...))` |
| Thickness | Constructor `width` (logical pixels) |
| Rounded corners | Set `BoxDecoration.borderRadius`; passed into `paint` |

---

## Examples {#gradient-box-borders-example}

Rectangle, rounded corners, and linear gradient (matches the `example` app):

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: GradientBoxBorders(
      gradient: LinearGradient(
        colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      width: 2,
    ),
  ),
);
```

::: tip
`GradientBoxBorders` draws only the **border**. Add `BoxDecoration.color` or `gradient` for fill. `width` contributes to `dimensions` (`EdgeInsets.all(width)`).
:::

---

## API reference {#gradient-box-borders-api}

---

#### `GradientBoxBorders` constructor {#gradient-box-borders-constructor}

```dart
const GradientBoxBorders({
  required Gradient gradient,
  required double width,
});
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `gradient` | `Gradient` | yes | Border colors; `createShader(rect)` uses the paint bounds. |
| `width` | `double` | yes | Stroke width (`PaintingStyle.stroke`). |

---

#### `paint` behavior {#gradient-box-borders-paint}

Implements `BoxBorder.paint`: rectangle path or oval from `shape`; rectangles honor `borderRadius` when set.

| Argument | Description |
| --- | --- |
| `shape` | `BoxShape.rectangle` (default) or `BoxShape.circle` |
| `borderRadius` | Rectangle only; should match `BoxDecoration.borderRadius` |

`scale` returns `this` (line width is not scaled by `t`).

---

## Recipes {#gradient-box-borders-recipes}

### Circular avatar ring {#gradient-box-borders-circle}

```dart
Container(
  width: 64,
  height: 64,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: GradientBoxBorders(
      gradient: LinearGradient(colors: [Colors.purple, Colors.orange]),
      width: 3,
    ),
  ),
  child: ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover)),
);
```

### Card with content {#gradient-box-borders-child}

`BoxBorder` does not wrap a `child`; put content on the outer `Container` and add padding so text does not sit under the stroke:

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Theme.of(context).colorScheme.surface,
    border: GradientBoxBorders(
      gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      width: 2,
    ),
  ),
  child: Text('Content'),
);
```
