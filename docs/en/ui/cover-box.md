---
title: Cover Layout
outline: [2, 3]
---

## Overview {#overview}

**Cover** layout matches CSS `object-fit: cover`: preserve aspect ratio, fill a fixed box, clip overflow. This package does **not** ship a widget named `CoverBox`. In Flutter, use `BoxFit.cover`, or when you need exact sizes use [Size calculation tools](/en/features/scan-size) (`fastCoverScanSize` / `fastCoverScanScale`).

| Approach | When |
| --- | --- |
| `Image` + `BoxFit.cover` | Photos / network images—simplest |
| `ClipRect` + `Transform.scale` | Known intrinsic size, custom child (video frame, canvas) |
| `fastCoverScanSize` / `fastCoverScanScale` | Numeric layout or animation |

---

## `BoxFit.cover` (recommended) {#cover-boxfit}

Fill a fixed box and clip:

```dart
import 'package:flutter/material.dart';

SizedBox(
  width: 200,
  height: 200,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      imageUrl,
      fit: BoxFit.cover,
    ),
  ),
);
```

`DecorationImage` also supports `fit: BoxFit.cover`:

```dart
Container(
  width: double.infinity,
  height: 180,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    image: DecorationImage(
      image: NetworkImage(imageUrl),
      fit: BoxFit.cover,
    ),
  ),
);
```

---

## With scan utilities {#cover-with-scan}

When the child is not an `Image`, or you want the same rules as [scan-size](/en/features/scan-size):

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

Widget coverChild({
  required Size boxSize,
  required Size contentSize,
  required Widget child,
}) {
  final scale = fastCoverScanScale(boxSize, contentSize);

  return SizedBox(
    width: boxSize.width,
    height: boxSize.height,
    child: ClipRect(
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: contentSize.width,
            height: contentSize.height,
            child: child,
          ),
        ),
      ),
    ),
  );
}
```

You can also set `SizedBox` dimensions from `fastCoverScanSize(boxSize, contentSize)` and clip to the container.

---

## Notes {#cover-notes}

- **Constraints**: Give the child a bounded size (`SizedBox`, `Expanded`, etc.) so cover has a clip region.
- **Performance**: Large images benefit from `cacheWidth` / `cacheHeight` or smaller URLs—orthogonal to cover math but important in lists.
- **vs `contain`**: `BoxFit.contain` shows the whole image with possible letterboxing; `cover` fills the box and may crop.
