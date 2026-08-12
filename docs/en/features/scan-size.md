---
title: Size Calculation Tools
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/utils/fast_scan" target="_blank" rel="noreferrer">Source on GitHub</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/utils/fast_scan/</code>
</p>

## Overview {#overview}

Top-level helpers `fastCoverScanSize` and `fastCoverScanScale` implement **cover** sizing similar to CSS **`object-fit: cover`**: given a parent box and a child’s intrinsic size, they compute either the **target size** or a **uniform scale factor** while preserving the child’s aspect ratio. Both take Flutter `Size` (width × height) and share the same algorithm.

| API | Returns | Typical use |
| --- | --- | --- |
| `fastCoverScanSize` | `Size` | Layout (`SizedBox`, custom paint) |
| `fastCoverScanScale` | `double` | `Transform.scale`, animation, multiply original dimensions |

Clip overflow with `ClipRect` / `ClipRRect`; common cover patterns are in [Cover layout](/en/ui/cover-box).

---

## Algorithm {#algorithm}

1. **Zero dimensions** — If any side of `parentSize` or `childSize` is `0`, `fastCoverScanSize` returns **`childSize` unchanged**; `fastCoverScanScale` returns **`1.0`** (avoids division by zero).
2. **Aspect ratio** — `aspect = width / height` for parent and child.
3. **Pick an axis** (cover without distortion):
   - Parent aspect **≥** child aspect: align by **width**, `scale = parent.width / child.width`
   - Parent aspect **<** child aspect: align by **height**, `scale = parent.height / child.height`
4. **Relationship** — With non-zero sizes, `fastCoverScanSize(parent, child)` equals  
   `Size(child.width * s, child.height * s)` where `s = fastCoverScanScale(parent, child)`.  
   **`s` may be less than 1** when the child is already larger but still needs cover alignment.

---

## `fastCoverScanSize` {#fast-cover-scan-size}

Returns the smallest uniformly scaled `Size` that covers `parentSize` while keeping the child’s aspect ratio (one dimension matches the parent; the other may extend beyond and is usually clipped).

### Examples {#fast-cover-scan-size-example}

::: code-group

```dart [Scale by width]
import 'package:fast_package/fast_package.dart';

// Parent 100×100, child 50×80 — parent is “squarer”, align by width
fastCoverScanSize(Size(100, 100), Size(50, 80));
// Size(100.0, 160.0)
```

```dart [Scale by height]
// Parent 200×100, child 100×100 — child is “squarer”, align by height
fastCoverScanSize(Size(200, 100), Size(100, 100));
// Size(200.0, 200.0)
```

```dart [Zero dimension]
fastCoverScanSize(Size(100, 0), Size(50, 80));
// Size(50.0, 80.0) — original childSize
```

:::

### API reference {#fast-cover-scan-size-api}

---

#### `fastCoverScanSize` {#fast-cover-scan-size-fn}

```dart
Size fastCoverScanSize(Size parentSize, Size childSize);
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `parentSize` | `Size` | yes | Parent (viewport) size. |
| `childSize` | `Size` | yes | Child’s original size. |

| Return | Type | Description |
| --- | --- | --- |
| Cover size | `Size` | Same aspect ratio as `childSize`; if any side is zero, returns `childSize`. |

---

## `fastCoverScanScale` {#fast-cover-scan-scale}

Returns the uniform scale factor `s` from the same rules; multiplying child width and height by `s` matches `fastCoverScanSize`.

### Examples {#fast-cover-scan-scale-example}

::: code-group

```dart [Scale up to cover]
fastCoverScanScale(Size(100, 100), Size(50, 50));
// 2.0 — same aspect ratio, by width: 100 / 50
```

```dart [Wide child, height axis]
// Parent 100×100, child 200×100 — height alignment is enough
fastCoverScanScale(Size(100, 100), Size(200, 100));
// 1.0
```

```dart [Flat child, height axis]
// Parent 100×100, child 100×50
fastCoverScanScale(Size(100, 100), Size(100, 50));
// 2.0 — parent.height / child.height
```

:::

### API reference {#fast-cover-scan-scale-api}

---

#### `fastCoverScanScale` {#fast-cover-scan-scale-fn}

```dart
double fastCoverScanScale(Size parentSize, Size childSize);
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `parentSize` | `Size` | yes | Parent size. |
| `childSize` | `Size` | yes | Child’s original size. |

| Return | Type | Description |
| --- | --- | --- |
| Scale factor | `double` | `1.0` if any side is zero; otherwise width- or height-based ratio (may be greater or less than 1). |

---

## Flutter notes {#flutter-practice}

When you know container and image pixel sizes, compute scale first and clip overflow:

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

Widget coverImage({
  required Size containerSize,
  required Size imageSize,
  required ImageProvider image,
}) {
  final scale = fastCoverScanScale(containerSize, imageSize);

  return SizedBox(
    width: containerSize.width,
    height: containerSize.height,
    child: ClipRect(
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Image(
            image: image,
            width: imageSize.width,
            height: imageSize.height,
          ),
        ),
      ),
    ),
  );
}
```

For simple network images, `Image` with `BoxFit.cover` (see [Cover layout](/en/ui/cover-box)) is often enough. These functions shine when you need numeric sizes for **custom layout, animation, or non-`Image` children** (canvas, video frames).

Typical cases: full-bleed backgrounds, video cover fit, thumbnail grids, responsive banners with fixed height.
