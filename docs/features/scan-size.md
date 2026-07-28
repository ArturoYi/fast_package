---
title: 尺寸计算工具
outline: [2, 3]
---

## 概览 {#overview}

顶层函数 `fastCoverScanSize` 与 `fastCoverScanScale` 实现类似 CSS **`object-fit: cover`** 的覆盖适配：在保持子元素宽高比的前提下，计算「铺满父容器」所需的**目标尺寸**或**统一缩放因子**。二者算法一致，入参均为 Flutter `Size`（宽 × 高）。

| API | 返回值 | 典型用途 |
| --- | --- | --- |
| `fastCoverScanSize` | `Size` | 直接得到布局宽高（`SizedBox`、自定义绘制） |
| `fastCoverScanScale` | `double` | `Transform.scale`、动画、与原始尺寸相乘 |

需在 Widget 层裁剪溢出时，可配合 `ClipRect` / `ClipRRect`；常见 Cover 写法见 [Cover 布局](/ui/cover-box)。

---

## 算法说明 {#algorithm}

1. **零维度**：若 `parentSize` 或 `childSize` 任一边为 `0`，`fastCoverScanSize` **原样返回** `childSize`；`fastCoverScanScale` 返回 **`1.0`**（避免除零）。
2. **宽高比**：`aspect = width / height`，分别计算父、子宽高比。
3. **选轴缩放**（保证覆盖且不变形）：
   - 父宽高比 **≥** 子宽高比：按**宽度**对齐，`scale = parent.width / child.width`
   - 父宽高比 **<** 子宽高比：按**高度**对齐，`scale = parent.height / child.height`
4. **两 API 关系**：在非零维度下，`fastCoverScanSize(parent, child)` 等价于  
   `Size(child.width * s, child.height * s)`，其中 `s = fastCoverScanScale(parent, child)`。  
   缩放因子 **可以小于 1**（子元素已比父容器「大」但仍需按 cover 规则对齐时）。

---

## `fastCoverScanSize` {#fast-cover-scan-size}

在保持子元素比例的前提下，返回覆盖 `parentSize` 所需的最小放大（或缩小）后的 `Size`（某一维与父容器对齐，另一维可能超出，由外层裁剪）。

### 基础使用示例 {#fast-cover-scan-size-example}

::: code-group

```dart [按宽度缩放]
import 'package:fast_package/fast_package.dart';

// 父 100×100，子 50×80 → 父更「方」，按宽对齐
fastCoverScanSize(Size(100, 100), Size(50, 80));
// Size(100.0, 160.0)
```

```dart [按高度缩放]
// 父 200×100，子 100×100 → 子更「方」，按高对齐
fastCoverScanSize(Size(200, 100), Size(100, 100));
// Size(200.0, 200.0)
```

```dart [零维度]
fastCoverScanSize(Size(100, 0), Size(50, 80));
// Size(50.0, 80.0) — 返回原始 childSize
```

:::

### 完整 API 参考 {#fast-cover-scan-size-api}

---

#### `fastCoverScanSize` {#fast-cover-scan-size-fn}

```dart
Size fastCoverScanSize(Size parentSize, Size childSize);
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `parentSize` | `Size` | 是 | 父容器（视口）尺寸。 |
| `childSize` | `Size` | 是 | 子内容原始尺寸。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| 覆盖尺寸 | `Size` | 与 `childSize` 同宽高比；任一边为 0 时返回 `childSize`。 |

---

## `fastCoverScanScale` {#fast-cover-scan-scale}

返回与上文相同的统一缩放因子 `s`；对子元素宽高同时乘以 `s` 即得到 `fastCoverScanSize` 的结果。

### 基础使用示例 {#fast-cover-scan-scale-example}

::: code-group

```dart [放大覆盖]
fastCoverScanScale(Size(100, 100), Size(50, 50));
// 2.0 — 宽高比相同，按宽度：100 / 50
```

```dart [子更宽时按高度]
// 父 100×100，子 200×100 — 按高度对齐即可铺满
fastCoverScanScale(Size(100, 100), Size(200, 100));
// 1.0
```

```dart [子更扁时按高度]
// 父 100×100，子 100×50
fastCoverScanScale(Size(100, 100), Size(100, 50));
// 2.0 — parent.height / child.height
```

:::

### 完整 API 参考 {#fast-cover-scan-scale-api}

---

#### `fastCoverScanScale` {#fast-cover-scan-scale-fn}

```dart
double fastCoverScanScale(Size parentSize, Size childSize);
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `parentSize` | `Size` | 是 | 父容器尺寸。 |
| `childSize` | `Size` | 是 | 子内容原始尺寸。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| 缩放因子 | `double` | 任一边为 0 时返回 `1.0`；否则为按宽或按高选轴后的比例（可大于 1 或小于 1）。 |

---

## Flutter 实践 {#flutter-practice}

已知容器与图片原始像素尺寸时，可先算缩放再布局（溢出部分由裁剪隐藏）：

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

若只需展示网络图且不关心精确像素，多数场景直接使用 `Image` 的 `BoxFit.cover`（见 [Cover 布局](/ui/cover-box)）即可；上述函数适合**自定义布局、动画、非 `Image` 子树**（如 `Canvas`、视频帧尺寸）需要先算出数值的场景。

常见场景：全屏背景图、视频画面 letterbox/cover、缩略图网格统一裁切比例、响应式 Banner 在固定高度下算宽度。
