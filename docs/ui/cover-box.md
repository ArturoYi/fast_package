---
title: Cover 布局
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/utils/fast_scan" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/utils/fast_scan/</code>
</p>

## 概览 {#overview}

「Cover」指类似 CSS `object-fit: cover` 的铺满效果：内容保持宽高比，填满固定尺寸的容器，超出部分裁剪。本包 **未提供** 名为 `CoverBox` 的 Widget；在 Flutter 中通常用 `BoxFit.cover`，或在需要精确像素时用 [尺寸计算工具](/features/scan-size) 中的 `fastCoverScanSize` / `fastCoverScanScale`。

| 方式 | 适用 |
| --- | --- |
| `Image` + `BoxFit.cover` | 图片 / 网络图、最简单 |
| `ClipRect` + `Transform.scale` | 已知原始尺寸、自定义子树（视频帧、Canvas） |
| `fastCoverScanSize` / `fastCoverScanScale` | 先算数值再布局或做动画 |

---

## `BoxFit.cover`（推荐） {#cover-boxfit}

固定宽高容器内让图片覆盖并居中裁剪：

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

`DecorationImage` 同样支持 `fit: BoxFit.cover`：

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

## 与尺寸工具配合 {#cover-with-scan}

当子元素不是 `Image`、或需要与 [scan-size](/features/scan-size) 算法一致的缩放因子时：

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

也可直接使用 `fastCoverScanSize(boxSize, contentSize)` 作为 `SizedBox` 的宽高，再配合 `ClipRect` 限制在容器内。

---

## 注意点 {#cover-notes}

- **布局约束**：子组件需有明确边界（如外层 `SizedBox` / `Expanded`），否则 `cover` 无法确定裁剪区域。
- **性能**：大图建议配合 `cacheWidth` / `cacheHeight` 或缩略图 URL，与 cover 算法无关但影响列表滚动性能。
- **与 `contain` 区别**：`BoxFit.contain` 完整显示内容可能留边；`cover` 铺满容器可能裁切。
