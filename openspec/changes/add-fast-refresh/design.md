## Context

`fast_package` 的 UI Kit（Toast、Shimmer、渐变边框）都是 SDK-only、API 显式。刷新/加载需要对齐 EasyRefresh 的核心协议：自定义 `ScrollPhysics` 计算越界，`Header`/`Footer` notifier 推状态机，再跑 `onRefresh`/`onLoad`。第一版只做垂直 bouncing 列表，避免把 EasyRefresh 的二楼、嵌套滚动和夹紧动画一并搬进来。

## Goals / Non-Goals

**Goals:**

- 用 `FastRefresh` 包裹任意垂直 `ScrollView`，注入同一份 physics。
- 状态机：`inactive → drag → armed → ready → processing → processed → done → inactive`。
- 任务结果：`success` / `fail` / `noMore`；`noMore` 锁 Footer，直到 `resetFooter` 或刷新成功且 `resetAfterRefresh`。
- Footer 默认触底自动加载（`infiniteOffset`）；Header 必须拉过阈值再松手。
- Controller 可编程触发/结束；回调也可返回 `FastRefreshResult`。
- 一种 Classic 指示器 + Builder 自定义。

**Non-Goals:**

- 二楼、NestedScrollView、横向、`clamping`、Locator/Listener、`refreshOnStart`、`FastRefresh.builder`、多皮肤、分页状态机。

## Decisions

### 1. 只做 bouncing，不做 clamping

- **选择**：`clamping: false`，越界就是真实 `pixels` 越界，offset = 越过边界的距离。
- **原因**：夹紧模式需要独立 `AnimationController` 和大量 boundary 分支，Classic 默认也是 bouncing。
- **备选**：Material 式夹紧（列表不动、指示器叠上去）——第二版再加。

### 2. 垂直 + Stack `above`

- **选择**：Header 钉在顶部、Footer 钉在底部，高度等于当前 offset。
- **原因**：覆盖 90% 列表页，且不必实现 locator sliver。
- **备选**：`FastRefresh.builder` 把 physics 交给调用方——嵌套滚动时再加。

### 3. Footer 默认 `infiniteOffset = 70`

- **选择**：距底部小于 70 即进入 `processing`，不必先越界再松手。
- **原因**：分页列表的常见手感；内容不足一屏时 `overExtent = 0`，避免空列表自己弹开。
- **备选**：只允许上拉过阈值——可通过 `FastClassicFooter(infiniteOffset: null)` 关掉。

### 4. 刷新与加载互斥

- **选择**：一方 `processing` 时另一方 `_canProcess == false`。
- **原因**：第一版状态机更简单，避免双任务改同一份列表。
- **备选**：`simultaneously`——后补。

### 5. 模块拆分，不用 `part`

- **选择**：独立文件 + `fast_package.dart` 导出；physics / notifier 不公开。
- **原因**：与 Toast/Shimmer 一致，避免 EasyRefresh 式巨型 library。

### 6. 默认文案用英文，调用方可覆盖

- **选择**：Classic 默认 `Pull to refresh` / `Loading...` 等英文。
- **原因**：包面向 pub.dev；中文在 example 与文档里演示覆盖。

## Risks / Trade-offs

- [手感与 EasyRefresh 不完全一致] → 对齐同一条状态机和 bouncing physics；不做皮肤与二楼。
- [子树多个 ScrollView 共用 physics] → 文档写明第一版不要在 `child` 里再嵌套可滚动组件。
- [触底加载在短列表上误触发] → 内容高度 ≤ 视口时 Footer `overExtent = 0`，且 `infiniteOffset` 可关。
- [松手时序错导致不触发] → 在 `createBallisticSimulation` 里先把 `userOffset` 置 false，再更新 mode，用 `releaseOffset` 判断是否进入 `ready`。

## Migration Plan

新 API，无迁移。发布后在 CHANGELOG 记为新增组件。失败则回退该模块导出即可。

## Open Questions

无。范围已在探索阶段拍板：垂直、触底加载、无 builder、无 `refreshOnStart`。
