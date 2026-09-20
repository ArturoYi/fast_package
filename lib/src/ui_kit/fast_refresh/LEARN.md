# FastRefresh 实现学习指南

给自己读的笔记，不进对外文档站。用法演示见 `example/lib/pages/refresh_example/` 和 `docs/ui/refresh.md`。

核心不是「画一个下拉箭头」，而是：**用自定义 `ScrollPhysics` 接管越界，再用 Header / Footer 状态机决定何时刷新 / 加载**。按下面顺序学，比从 `physics.dart` 硬啃更稳。

`openspec/changes/add-fast-refresh/design.md` 写的是更早的范围（不做 builder / 二楼 / clamping）。**以当前 `lib` 代码为准**。

## 总图

一次下拉刷新大致是这条链路：

```
手指拖动
  → _FRScrollPhysics          （摩擦、边界、弹簧）
  → 越界偏移 offset
  → Header / Footer Notifier
  → 状态机 mode
  → onRefresh / onLoad
  → Classic 指示器 UI
```

对应文件分工：

| 层 | 文件 | 职责 |
| --- | --- | --- |
| 协议 | `fast_refresh_indicator.dart` | 模式、结果、配置、快照 |
| 组装 | `fast_refresh_widget.dart`、`builder/fast_refresh_builder.dart`、`fast_refresh_behavior.dart` | 注入物理、叠 Header / Footer；Widget 构造 vs builder |
| 分页 | `fast_paging.dart`、`fast_paging_list.dart` | 页码 / 总数 / 空态接到 onRefresh / onLoad；日常用 `FastPagingList` |
| 外观 | `fast_refresh_theme.dart`、`widgets/fast_classic_*.dart`、`widgets/fast_material_indicator.dart` | Classic 默认；可选 Material；文案走 Theme |
| 控制 | `fast_refresh_controller.dart` | 编程触发 / 结束 / 重置；dispose 时解绑 |
| 状态机 | `fast_refresh_notifier.dart` | `offset` → `mode` → 任务 |
| 手感 | `fast_refresh_physics.dart` | 摩擦、边界钳制、弹簧回弹 |
| 进阶 | `header/`、`footer/` 的 locator、二楼、clamping、Nested | 特殊布局与坐标系 |

库入口是 `fast_refresh.dart`，其余文件以 `part of` 挂入。

## 需要掌握的知识

分三层。前两层是 Flutter 基础，第三层才是本组件特有的。

### Flutter 滚动底层

不先搞懂这些，`physics.dart` 会像黑魔法。

- **`Scrollable` / `ScrollPosition` / `ScrollMetrics`**：`pixels`、`minScrollExtent`、`maxScrollExtent`、`viewportDimension`、`outOfRange`
- **`ScrollPhysics` 三个入口**（本组件全重写了）：
  - `applyPhysicsToUserOffset`：手指还按着时，位移怎么折算（越界摩擦）
  - `applyBoundaryConditions`：这一帧哪些像素**不交给列表**、哪些同步给指示器
  - `createBallisticSimulation`：松手后的惯性 / 弹簧
- **`BouncingScrollPhysics` + `BouncingScrollSimulation` + `SpringDescription`**：iOS 橡皮筋、ready 吸到触发位
- **`ScrollConfiguration` / `ScrollBehavior`**：怎样把自定义 physics 塞进任意 `ListView`，并关掉系统 Glow

对照练习：自己写一个「只能越界 80px」的 `ScrollPhysics`，不接刷新。能写出来再读 `_FRScrollPhysics`。

### Flutter 状态与布局

- **`ChangeNotifier` / `ValueListenable` / `ValueListenableBuilder`**：notifier 一变，指示器重画
- **`InheritedWidget`**：`FastRefresh.of(context)` 给 Locator 取 Header / Footer
- **`TickerProvider` + `AnimationController`**：clamping 时列表不越界，指示器自己做动画
- **`Stack` + `Positioned`**：默认把 Header 钉在顶、Footer 钉在底
- **安全区 `MediaQuery.padding`**：实际触发距离 = `triggerOffset + safeOffset`

进阶布局（可以后学）：

- **`RenderBox` / `RenderSliver`**：Locator 占位为 0，却把指示器画到视口外侧
- **`NestedScrollView` 内外层**：`debugLabel == 'outer' / 'inner'`，视口尺寸要特殊处理

### 本组件特有概念

- **越界偏移 `offset`**：越过顶部 / 底部多少像素。Header 是 `minScrollExtent - pixels`，Footer 是 `pixels - maxScrollExtent`
- **状态机 `FastRefreshMode`**：

```
inactive → drag → armed → ready → processing → processed → done → inactive
                              ↘ secondary*（二楼，后学）
```

- **任务结果 `FastRefreshResult`**：`success` / `fail` / `noMore`；`noMore` 会锁 Footer
- **`clamping` vs bouncing**：列表跟着越界，还是列表卡住、只动指示器
- **`infiniteOffset`**：靠近边缘就加载（Footer 默认），不必先拉过阈值再松手
- **`overExtent`**：ready / processing / 无限加载时，物理层要**保持**的越界距离，弹簧才会吸在触发位而不是弹回 0
- **`userOffsetNotifier` + `_releaseOffset`**：区分「还按着」和「刚松手」，决定是 `armed` 还是 `ready`
- **刷新 / 加载互斥**：默认一方 `processing` 时另一方 `_canProcess == false`

## 建议学习顺序

不要从 `physics.dart` 第一行开始。按「先会用 → 再懂协议 → 再跟一帧数据 → 最后啃物理」走。

### 第 0 步：当用户用一遍

打开 `example/lib/pages/refresh_example/refresh_example.dart` 和 `docs/ui/refresh.md`。亲手试：

1. 下拉过阈值松手 → 刷新
2. 没过阈值松手 → 回弹、不刷新
3. 滑到底 → 自动加载
4. `controller.callRefresh()` / `finishRefresh()`
5. 返回 `noMore` 后再 `resetFooter`
6. Paging 页：`FastPaging` 用 `page` / `total` 自动收 `noMore`，空态和 refreshOnStart 占位

目标：知道**对外行为**，后面读代码才有对照。

分页不是另一套刷新。`fast_paging.dart` 只是把页码 / 总数 / 空态接到现有 `onRefresh` / `onLoad`。对照参考仓库的 `packages/easy_paging`。

### 第 1 步：协议层

读 `fast_refresh_indicator.dart`。只读枚举和 `FastRefreshIndicator` 字段，先不看实现。

必须能口头解释：

- `inactive` / `drag` / `armed` / `ready` / `processing` / `processed` / `done` 各自对应什么手势
- `triggerOffset` 和 `actualTriggerOffset`（含安全区）的差别
- `position`：`above` / `behind` / `locator` / `custom`
- 为什么 `FastRefreshIndicatorState` 是「快照」而不是 Widget 自己持有状态

### 第 2 步：组装层

读 `fast_refresh_widget.dart`、`builder/fast_refresh_builder.dart`、`fast_refresh_behavior.dart`。看 `_FastRefreshState._initData` 和 `_buildContent`：

1. 创建一对 Header / Footer notifier + 一份 `_FRScrollPhysics`
2. 用 `ScrollConfiguration` 注入 physics（`behavior.dart` 关掉系统越界光）
3. 按 `position` 用 `Stack` 叠指示器
4. `onRefresh == null` 时换成 `FastNotRefreshHeader`（手感还在，不画、不跑任务）

这一步结束，应能画出「谁创建谁、数据怎么往下传」。

### 第 3 步：控制面

读 `fast_refresh_controller.dart`。很短，用来确认公开入口都只是转调 notifier：

- `callRefresh` → `animateToOffset` 越过触发位 → 弹簧吸回 → `processing`
- `finishRefresh` 只在 `controlFinishRefresh == true` 时有意义
- 二楼 `openHeaderSecondary` 可以先跳过

### 第 4 步：状态机心脏

读 `fast_refresh_notifier.dart` 基类。这是最值得精读的文件。建议**只跟垂直 bouncing Header**，按方法读：

1. `_updateOffset`：physics 每帧把像素写成 `offset`。指示器 `listenable` 在 layout 期间把 `setState` 延到帧后，避免 `Build scheduled during frame`
2. `_slightDeviation`：把 `70.01` 吸成 `70`，否则 ready 进不了 processing
3. `_updateMode`：整张状态表
4. `_onTask`：跑回调；抛错记 `fail`，不往外抛
5. `_setMode` → `_scheduleProcessedCompletion` → `done` → 仍越界才 `_resetBallistic` 回弹（内容变高且已回范围内则不打断惯性）
6. `overExtent`：为什么 processing 时列表不会弹回 0

先不要深挖 Header / Footer 的 `_calculateOffset` 和 `animateToOffset`。把 `_updateMode` 在纸上画成状态图，比继续往下读更有用。

对照测试：`test/fast_refresh_test/fast_refresh_test.dart` 里每个用例对应一条状态路径。

### 第 5 步：物理层

有了状态机再读 `fast_refresh_physics.dart`，否则满屏边界分支没有意义。

按三个方法读：

1. `applyPhysicsToUserOffset`：越界越「涩」（friction），往回松更滑
2. `applyBoundaryConditions`：Header 一段、Footer 一段；返回值是**不交给列表的像素**
3. `createBallisticSimulation`：先把 `userOffsetNotifier` 置 `false`（标记已松手），再算弹簧；`leadingExtent` / `trailingExtent` 会加上 `overExtent`

读的时候始终问一句：**这一帧列表的 `pixels` 变了多少，指示器的 `offset` 变了多少？**

### 第 6 步：Header / Footer 不对称

同一套状态机，坐标系相反：

- `FastRefreshHeaderNotifier`：顶部外侧，`pixels` 为负
- `FastRefreshFooterNotifier`：底部外侧；内容不满一屏时 `overExtent = 0`，避免空列表自己弹开
- Footer 默认 `infiniteOffset = 0`（基类）/ Classic 默认 `70`，靠近底部就加载
- Header 默认必须拉过阈值再松手

再读两边的 `animateToOffset`：`callRefresh` 为什么要先越过阈值，再 `_resetBallistic` 吸回去。

### 第 7 步：外观

读 `widgets/fast_classic_indicator.dart`。这时已经知道 `mode` / `offset`，UI 只是翻译：

- `drag → armed`：箭头旋转
- `ready / processing`：转圈
- `processed`：成功 / 失败 / 无更多
- locator + 无限加载时，高度钉在 `actualTriggerOffset`，避免回弹把指示器挤没

`widgets/fast_classic_header.dart` / `widgets/fast_classic_footer.dart` 只是默认文案和 `reverse` 方向不同。

### 第 8 步：进阶

有需要再学，建议按难度：

1. **`clamping`**：列表不越界，`AnimationController` 驱动指示器
2. **`FastRefresh.builder`**：自己把 physics 挂到 `NestedScrollView` / 嵌套滚动
3. **Locator**：`header/fast_header_locator.dart` / `footer/fast_footer_locator.dart`，指示器进列表内部
4. **二楼**：`secondaryArmed → secondaryOpen`
5. **`isNested`**：内外层视口、外层正向回推要忽略

这些是「同一套协议的变体」，不是另一套刷新。

## 最小跟读路径

用调试器在 example 里下拉一次，只打这几个断点：

1. `_FRScrollPhysics.applyPhysicsToUserOffset`
2. `FastRefreshNotifier._updateOffset`
3. `FastRefreshNotifier._updateMode`
4. `_FRScrollPhysics.createBallisticSimulation`
5. `FastRefreshNotifier._onTask`

看同一轮手势里：`pixels`、`offset`、`mode`、`userOffsetNotifier` 怎么变。能口述这一轮，就算真正掌握了。

## 怎样算学会了

能独立回答这 5 个问题：

1. 为什么没过阈值松手不会刷新？（`_releaseOffset` + `armed` vs `ready`）
2. 为什么 processing 时列表停在触发位，不会弹回？（`overExtent`）
3. 为什么 `callRefresh` 要先拉过阈值再吸回去？（`animateToOffset` + `_resetBallistic`）
4. 为什么 Footer 滑到底就会加载，Header 却要松手？（`infiniteOffset`）
5. bouncing 和 clamping 的 `offset` 分别从哪来？（真实 `pixels` vs `AnimationController`）

前 4 问能答清，主路径就通了；第 5 问通了，进阶模式才接得上。
