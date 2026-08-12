---
title: Shimmer 骨架屏
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_shimmer" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_shimmer/</code>
</p>

## 概览 {#overview}

`FastShimmer` 系列提供**手写骨架屏**与同步扫光动画：用 `FastShimmerBox` / `FastShimmerCircle` / `FastShimmerText` / `FastShimmerList` 拼布局，由 `FastShimmerScope` 用单个 `AnimationController` + `ShaderMask` 驱动整棵子树同相位扫光。

| 要点 | 说明 |
| --- | --- |
| 主入口 | `FastShimmer(isLoading, skeleton, child)` |
| 同步动画 | `FastShimmerScope`（无祖先 Scope 时由 `FastShimmer` 自动包裹） |
| 占位积木 | `Box` / `Circle` / `Text` / `List` |
| 主题 | `FastShimmerTheme`（`ThemeExtension`）+ `FastShimmerDirection` |
| **不做** | 从 `child` 自动推断骨架形状 |

::: tip
骨架子节点需**不透明**（包内占位默认白底），`ShaderMask` 的渐变才能可见。完整演示见 example 的 `ShimmerExample` 页。
:::

---

## 基础使用示例 {#shimmer-example}

加载态切换（推荐入口）：

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

仅展示骨架、自行控制作用域时：

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

## 注册主题 {#shimmer-theme-setup}

在 `ThemeData.extensions` 中注册，即可全局控制底色、高光、方向与默认时长感（时长仍可由 Scope / `FastShimmer` 的 `duration` 覆盖）：

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

解析优先级：

1. 组件构造参数显式覆盖（如独立模式下的 `baseColor`）
2. `ThemeData` 上的 `FastShimmerTheme` 扩展
3. 按 `ThemeData.brightness` 回退到 `FastShimmerTheme.light` / `dark`

---

## 完整 API 参考 {#shimmer-api}

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

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `child` | `Widget` | 是 | `isLoading == false` 时展示的真实内容 |
| `isLoading` | `bool` | 是 | `true` 显示 `skeleton`，`false` 显示 `child` |
| `skeleton` | `Widget` | 是 | 手写骨架；**不会**从 `child` 自动推断 |
| `duration` | `Duration` | 否 | 自动创建 Scope 时的扫光周期；已有祖先 Scope 时忽略 |

加载时会设置 Semantics（label `Loading`，并 `excludeSemantics`），且若已有祖先 `FastShimmerScope` 则**不再**包第二层，避免双重 `ShaderMask`。

---

#### `FastShimmerScope` {#fast-shimmer-scope}

```dart
const FastShimmerScope({
  required Widget child,
  Duration duration = const Duration(milliseconds: 1500),
});
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `child` | `Widget` | 是 | 接收扫光遮罩的骨架子树 |
| `duration` | `Duration` | 否 | 一次完整扫光循环时长，默认 1500 ms |

静态方法：

| 方法 | 说明 |
| --- | --- |
| `of(context)` | 最近 Scope 的动画值 `0.0`–`1.0`；无 Scope 时为 `0.5`（会订阅更新） |
| `maybeOf(context)` | 有 Scope 返回动画值，否则 `null`（会订阅） |
| `hasScope(context)` | 是否存在祖先 Scope，**不**订阅每帧更新（适合判断是否自动包裹） |

`MediaQuery.disableAnimations == true` 时，控制器停止并定格在 `0.5`（骨架仍可见、不移动）。`AnimatedBuilder` 会缓存 `child`，动画帧不会重建占位子树。

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

| 字段 / 成员 | 说明 |
| --- | --- |
| `baseColor` | 底色 |
| `highlightColor` | 扫过高光色 |
| `duration` | 主题中的周期（与 Scope 的 `duration` 对齐时更统一） |
| `direction` | 高光方向 |
| `light` / `dark` | 内置亮色 / 暗色默认 |
| `of(context)` | 读取扩展，可能为 `null` |
| `resolve(context, {…})` | 解析有效主题，并支持字段级覆盖 |
| `copyWith` / `lerp` | 标准 `ThemeExtension` 行为；`direction` 在 `t == 0.5` 处切换 |

默认值（摘要）：

| 主题 | `baseColor` | `highlightColor` | `duration` | `direction` |
| --- | --- | --- | --- | --- |
| `light` | `#E0E0E0` | `#F5F5F5` | 1500 ms | `leftToRight` |
| `dark` | `#2C2C2C` | `#3D3D3D` | 1500 ms | `leftToRight` |

---

#### `FastShimmerDirection` {#fast-shimmer-direction}

| 值 | 高光方向 |
| --- | --- |
| `leftToRight` | 左 → 右 |
| `rightToLeft` | 右 → 左 |
| `topToBottom` | 上 → 下 |
| `bottomToTop` | 下 → 上 |
| `diagonal` | 左上 → 右下 |

`toGradient({colors, stops})` 按方向生成 `LinearGradient`（供 Scope 内部每帧平移 `stops`）。

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

| 参数 | 说明 |
| --- | --- |
| `width` / `height` | 矩形尺寸（逻辑像素） |
| `borderRadius` | 圆角，默认直角 |
| `baseColor` | **仅独立模式**覆盖底色 |
| `highlightColor` / `direction` | 为 API 一致性保留；在 Scope 内不使用 |

Scope 内填充白色；无 Scope 时填充 `baseColor` 或主题底色（静态占位）。

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

| 参数 | 说明 |
| --- | --- |
| `diameter` | 直径（逻辑像素） |
| `baseColor` 等 | 与 `FastShimmerBox` 相同的独立 / Scope 填充策略 |

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

| 参数 | 说明 |
| --- | --- |
| `lines` | 横条数量，至少为 1 |
| `lineHeight` / `lineSpacing` | 行高与行距 |
| `width` | 非末行完整宽度 |
| `lastLineWidthFraction` | 末行相对 `width` 的比例，范围 `(0, 1]` |

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

| 参数 | 说明 |
| --- | --- |
| `itemCount` | 行数，非负 |
| `itemBuilder` | 自定义行；省略时为「圆形头像 + 两行文字」 |
| `separatorHeight` | 行间距 |
| `padding` / `shrinkWrap` / `physics` | 列表布局与滚动；默认不可滚动，便于嵌在父级 `ListView` 中 |

请用 `FastShimmerScope`（或 `FastShimmer`）包裹，使各行共享同一次扫光。

---

## 常见搭配 {#shimmer-recipes}

### 列表骨架 {#shimmer-list-recipe}

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

### 局部覆盖方向 / 颜色 {#shimmer-local-theme}

用内层 `Theme` 注入 `FastShimmerTheme`，只影响预览区或某一块骨架：

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

### 独立静态占位 {#shimmer-standalone}

无 Scope 时，占位仍可见（主题底色），只是没有扫光动画——适合调试布局或暂不需要动效的场景。

---

## 注意点 {#shimmer-notes}

- **手写骨架**：必须显式提供 `skeleton`；本能力不包含 auto-detect / shape detector。
- **一个 Scope**：建议每个页面或加载子树一个 Scope；嵌套允许但通常多余。
- **无障碍**：尊重 `MediaQuery.disableAnimations`；加载态由 `FastShimmer` 宣告 `Loading`。
- **性能**：扫光在 Scope 层完成，占位组件不会因动画帧重建；列表行数按需控制即可。
