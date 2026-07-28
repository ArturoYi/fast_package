---
title: 渐变边框
outline: [2, 3]
---

## 概览 {#overview}

`GradientBoxBorders` 是自定义 `BoxBorder`，用于在 `Container`、`DecoratedBox` 等 `BoxDecoration.border` 上绘制**渐变描边**（非纯色 `Border.all`）。支持矩形（可配合 `borderRadius` 圆角）与 `BoxShape.circle` 圆形；渐变由 Flutter `Gradient`（如 `LinearGradient`）定义。

| 要点 | 说明 |
| --- | --- |
| 用法位置 | `BoxDecoration(border: GradientBoxBorders(...))` |
| 粗细 | 构造函数 `width`（逻辑像素） |
| 圆角 | 写在 `BoxDecoration.borderRadius`，绘制时传入 `paint` |

---

## 基础使用示例 {#gradient-box-borders-example}

矩形 + 圆角 + 线性渐变（与 `example` 工程一致）：

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
`GradientBoxBorders` 只画**边框**；若需要填充背景色或渐变，请同时使用 `BoxDecoration.color` / `gradient`，并注意边框 `width` 会占用 `dimensions`（内边距为 `EdgeInsets.all(width)`）。
:::

---

## 完整 API 参考 {#gradient-box-borders-api}

---

#### `GradientBoxBorders` 构造函数 {#gradient-box-borders-constructor}

```dart
const GradientBoxBorders({
  required Gradient gradient,
  required double width,
});
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `gradient` | `Gradient` | 是 | 边框着色；`createShader(rect)` 作用于当前绘制区域。 |
| `width` | `double` | 是 | 描边线宽（`PaintingStyle.stroke`）。 |

---

#### `paint` 行为 {#gradient-box-borders-paint}

实现 `BoxBorder.paint`：根据 `shape` 绘制矩形路径或椭圆路径；矩形分支会使用 `borderRadius`（若有）生成 `RRect`。

| 参数 | 说明 |
| --- | --- |
| `shape` | `BoxShape.rectangle`（默认）或 `BoxShape.circle` |
| `borderRadius` | 仅矩形有效；圆角与 `BoxDecoration.borderRadius` 一致 |

`scale` 返回 `this`（不随布局缩放改变线宽逻辑）。

---

## 常见搭配 {#gradient-box-borders-recipes}

### 圆形头像描边 {#gradient-box-borders-circle}

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

### 带内容的卡片 {#gradient-box-borders-child}

边框类 `BoxBorder` 不包裹 `child`；内容放在外层 `Container` 的 `child`，内边距需自行留出边框宽度，避免文字贴边：

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
  child: Text('内容'),
);
```
