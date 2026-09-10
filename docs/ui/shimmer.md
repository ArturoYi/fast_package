---
title: Shimmer 扫光
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_shimmer" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_shimmer/</code>
</p>

<DocCredit module="shimmer" />

## 概览 {#overview}

`FastShimmer` 系列提供**手写骨架屏**与**装饰性扫光**：用 `FastShimmerBox` / `FastShimmerCircle` / `FastShimmerText` / `FastShimmerList` 拼加载骨架；用 `FastShimmerHighlight` 给真实文字 / 图标 / 滑块打上一道细白光束。扫光由 `FastShimmerScope` 用单个 `AnimationController` + `ShaderMask` 驱动，同一 Scope 下子树同相位。

| 要点 | 说明 |
| --- | --- |
| 加载入口 | `FastShimmer(isLoading, skeleton, child)` |
| 同步动画 | `FastShimmerScope`（无祖先 Scope 时由 `FastShimmer` / `FastShimmerHighlight` 自动包裹） |
| 占位积木 | `Box` / `Circle` / `Text`（骨架横条） / `List` |
| 装饰扫光 | `FastShimmerHighlight`（细光束） / `FastShimmerSlideUnlock`（可拖动；`area` 整条区域 / `label` 仅文字） |
| 主题 | `FastShimmerTheme`（`ThemeExtension`）+ `FastShimmerDirection` |
| **不做** | 从 `child` 自动推断骨架形状；拖动时不把字色变浅 |

::: tip
被扫光的像素必须**不透明**（骨架占位默认白底；真实文字用实心字形色，便捷构造会写成白色）。`ShaderMask` 的可见颜色来自主题，不是子节点自己的 `color`。完整演示见 example 的 `ShimmerExample` 入口（骨架屏 / 扫光文字 / 滑动解锁）。
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

## 装饰性扫光 {#shimmer-highlight}

`FastShimmerText` 是**骨架横条**。要让真实文字发亮，用 `FastShimmerHighlight` 包一层不透明的 `Text` / `Icon`：

```dart
FastShimmerHighlight.text(
  '滑动解锁',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0x66FFFFFF), // 未传 baseColor 时当作扫光底色
  ),
  highlightColor: Colors.white,
);
```

默认动效是一道细白高光带：约 **3 秒**从左扫到右，扫完**停顿约 1.8 秒**再循环。字色保持不变，不会随动画变浅。`ShaderMask` 只给 child 的不透明像素着色，轨道 / 卡片背景放在 Scope 外面就不会动。

任意不透明子节点都可以：

```dart
FastShimmerHighlight(
  baseColor: const Color(0xFF9E9E9E),
  highlightColor: Colors.white,
  child: const Icon(Icons.chevron_right, color: Colors.white),
);
```

可拖动的滑动解锁：斜向柔光约 **3 秒**从左扫到右，扫完停顿约 **1.8 秒**再循环。两种贴法共用这套参数——`area` 扫整条金属胶囊（文案居中叠在上面），`label` 只扫居中的提示字形（轨道和滑钮不动）。页面 / 卡片背景放在控件外面就不会动；拖动时字色不变浅；`resetOnUnlock` 控制解锁后是否复位：

```dart
FastShimmerSlideUnlock(
  label: '滑动解锁',
  highlight: FastShimmerSlideUnlockHighlight.area, // 或 .label
  successLabel: '已解锁',
  resetOnUnlock: true,
  onUnlocked: _unlock,
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
  Duration pauseDuration = Duration.zero,
  FastShimmerSweep sweep = FastShimmerSweep.wash,
  double bandWidth = 0.18,
  double sheenRotation = FastShimmerScope.beamSheenRotation,
});
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `child` | `Widget` | 是 | 接收扫光遮罩的骨架子树 |
| `duration` | `Duration` | 否 | **扫过**时长（不含停顿），骨架默认 1500 ms |
| `pauseDuration` | `Duration` | 否 | 扫完后的停顿，默认 `0`（骨架连续扫） |
| `sweep` | `FastShimmerSweep` | 否 | `wash` 宽幅洗刷（骨架）；`beam` 斜向柔光（装饰） |
| `bandWidth` | `double` | 否 | 高光带相对扫光轴的宽度比例，仅 `beam` 使用；越大越软 |
| `sheenRotation` | `double` | 否 | `beam` 的倾斜角（弧度），默认约 -0.45；文字扫光可用 `0` 水平扫 |

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

这是段落**骨架**，不是真实文字扫光。真实字形请用 `FastShimmerHighlight`。

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

| 参数 | 说明 |
| --- | --- |
| `child` | 接收扫光的不透明内容（通常是实心 `Text` / `Icon` / 滑块） |
| `duration` | 扫过时长，默认 **3 s**；已有祖先 Scope 时忽略 |
| `pauseDuration` | 扫完停顿，默认 **1.8 s** |
| `bandWidth` | 细光束宽度比例，默认 `0.18` |
| `baseColor` / `highlightColor` / `direction` | 仅在本组件自己创建 Scope 时覆盖主题 |

`text` 便捷构造会把字形色改成不透明白，以便 `ShaderMask` 着色。未传 `baseColor` 时，会把 `style.color` 当作扫光底色。已有祖先 `FastShimmerScope` 时**不再**包第二层，颜色 / 时序覆盖也不生效。自动创建的 Scope 使用 `FastShimmerSweep.beam`。

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

| 参数 | 说明 |
| --- | --- |
| `label` | 提示文案（拖动时不变浅） |
| `successLabel` | 解锁成功后的文案；可空 |
| `onUnlocked` | 越过 `threshold` 并就位到终点时回调一次 |
| `threshold` | 解锁所需进度，范围 `(0, 1]`，默认 `0.85` |
| `enabled` | 为 `false` 时不可拖动 |
| `resetOnUnlock` | 回调后是否把滑块复位（默认 `true`） |
| `highlight` | `area` 整条胶囊扫光；`label` 仅文字（默认） |
| `duration` / `pauseDuration` | 细光束扫过 / 停顿，默认 3 s / 1.8 s；两种贴法共用 |

光束沿滑块宽度行进。`area` 把不透明胶囊放进遮罩（金属高光），文案和滑钮叠在上面；`label` 只有字形不透明，轨道和滑钮在遮罩外。RTL 下从右侧滑向左侧。

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

### 扫光文字 {#shimmer-text-recipe}

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

### 滑动解锁 {#shimmer-slide-unlock-recipe}

```dart
FastShimmerSlideUnlock(
  label: '滑动解锁',
  highlight: FastShimmerSlideUnlockHighlight.area,
  successLabel: '已解锁',
  resetOnUnlock: true,
  onUnlocked: () {
    // 解锁后的业务
  },
);
```

完整对照见 example 的 `shimmer_example/slide_hint`。

---

## 注意点 {#shimmer-notes}

- **手写骨架**：必须显式提供 `skeleton`；本能力不包含 auto-detect / shape detector。
- **两种文字**：`FastShimmerText` = 骨架横条；`FastShimmerHighlight` = 真实字形上的细光束。
- **wash vs beam**：骨架默认 `wash` 宽幅连续扫；装饰默认 `beam`（斜向柔光，3 s 扫过 + 1.8 s 停顿）。
- **一个 Scope**：建议每个页面或加载子树一个 Scope；嵌套允许但通常多余。`FastShimmerHighlight` 放在加载 Scope 里面时会复用祖先扫光，局部颜色 / 时序覆盖无效。
- **不透明像素**：`BlendMode.srcIn` 把子节点当遮罩，可见色来自扫光渐变。背景放在 Scope 外就不会动。文字扫光请用**不透明**底色（半透明白叠在白字形上会抵消高光）。字色不会随动画变浅。
- **无障碍**：尊重 `MediaQuery.disableAnimations`；加载态由 `FastShimmer` 宣告 `Loading`。
- **性能**：扫光在 Scope 层完成，占位组件不会因动画帧重建；列表行数按需控制即可。
