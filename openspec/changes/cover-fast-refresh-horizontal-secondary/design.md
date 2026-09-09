## Context

`FastRefresh` 内核已对齐 EasyRefresh 的横向轴与二楼：`triggerAxis`、横轴 Header/Footer 定位、Classic 横轴布局、`FastSecondaryBuilderHeader`、`openHeaderSecondary` / `closeHeaderSecondary`、物理层二楼锁定。`cover-fast-refresh-scenarios` 已把竖列表六页（Widget / Builder / Nested / Locator / refreshOnStart / clamping）补齐，并明确不做横向与二楼示例。

本轮只覆盖已有 API，不扩内核、不加包装器。对照仓库是本机 `flutter_easy_refresh-3` 的 `page_view_page.dart`、`classical_page.dart`（切轴）、`secondary_page.dart` 和 `horizontal_scroll_test.dart`，只抄场景结构，不引入 Rive / GetX / 皮肤包。

## Goals / Non-Goals

**Goals:**

- Refresh 示例入口从六页加到八页：横向、Header 二楼。
- 横向页能横拉刷新 / 加载；同一页可切到 `PageView`（Footer 关无限加载）。
- 二楼页能用手势或控制器打开 / 关闭 Header 二楼；二楼页是纯色或渐变，不要 Rive。
- Widget 测试覆盖横轴与二楼主路径。
- 中英文文档写出可抄配方，并指向这两页 example。

**Non-Goals:**

- 新增公开 API（含 `FastSecondaryPageHeader`）。
- Footer 二楼示例、`reverse`、Listener、TabBarView。
- 重写 physics / 状态机，或把 `part of` 拆库。
- Material / Cupertino 皮肤、分页、主题。
- 整页移植 EasyRefresh 二楼（Rive、插槽机、GetX）。

## Decisions

### 1. 示例仍从入口 push，不加 named route

- **选择**：沿用 `RefreshExample` 的 `Navigator.push` + 分目录。
- **原因**：现有六页已是这套；八页仍是 Refresh 子系统。
- **备选**：独立 named route——和现有入口不一致，且不是本轮目标。

目录：

```
example/lib/pages/refresh_example/
  refresh_example.dart                    # 入口加两行
  horizontal/refresh_horizontal_example.dart
  secondary/refresh_secondary_example.dart
```

### 2. 两页怎么挂 FastRefresh

| 页 | 构造 | 要点 |
| --- | --- | --- |
| 横向 | `FastRefresh` Widget 构造 | `ListView.builder(scrollDirection: Axis.horizontal)`；AppBar 在外；`clipBehavior: Clip.none`；可用 AppBar action 切到 `PageView`。`PageView` 时 Footer `infiniteOffset: null`，否则一翻页就 `onLoad`。`triggerAxis` 可不设（列表轴已是横向）。 |
| 二楼 | `FastRefresh` Widget 构造 | `clipBehavior: Clip.none`。`FastSecondaryBuilderHeader` 包 `FastClassicHeader(position: locator, clipBehavior: Clip.none, safeArea: false)`。`secondaryTriggerOffset: 120`，`secondaryDimension` = 屏高 − `kToolbarHeight` − 顶安全区。`FastRefreshStateListenable` 同步 `SliverAppBar`（返回键、标题透明度）。`CustomScrollView` 里插 `FastHeaderLocator.sliver()`。二楼内容：全屏色块 + 短文案。`PopScope(canPop: false)` 在二楼打开 / 关闭中调用 `closeHeaderSecondary`。AppBar 提供「打开二楼」按钮走 `openHeaderSecondary`。 |

共用现有 example 的假分页（约 20 条、最多 3 页、`controlFinish*`）。二楼页 Footer 可用默认 Classic，但 **Header 不能带 `infiniteOffset`**（与二楼互斥）。

二楼 `builder` 最小结构（实现时按此抄，不要再发明一层抽象）：

```
Stack(clipBehavior: Clip.none)
  ├─ SizedBox(height: state.offset)          // locator 占位
  ├─ Positioned(bottom: 0) 全屏二楼页         // 透明度随 scale
  └─ 未进 secondaryReady/Open/Closing 时画 header.build(...)
```

`scale` 算法对齐 EasyRefresh：`offset > actualTriggerOffset` 时，

`(actualSecondaryTriggerOffset - offset) / (actualSecondaryTriggerOffset - actualTriggerOffset)`，夹在 0…1。

### 3. 测试按场景拆文件

- **选择**：不改 `fast_refresh_test.dart` 与上一轮四个场景文件，新增：
  - `fast_refresh_horizontal_test.dart`
  - `fast_refresh_secondary_test.dart`
- **原因**：横拖与二楼状态机和竖列表 harness 绑在一起会变脆。EasyRefresh 横轴已单独成文件；二楼他们几乎没测，我们补上。
- **备选**：塞进主文件——难对照失败。

横向对齐 `horizontal_scroll_test.dart` 的可靠子集：

- 挂载横向 `ListView`，`scrollDirection == Axis.horizontal`
- 横拖后 Header `axis == Axis.horizontal`，模式进入 `drag`（过阈值则 `armed`）
- `callRefresh` / `callLoad` 能跑回调
- Classic Header/Footer 能和横向列表一起构建

二楼（控制器优先，手势为辅）：

- 配置 `secondaryTriggerOffset` 后，`openHeaderSecondary` → Header `secondaryOpen`
- `closeHeaderSecondary` → `inactive` 且 offset 为 `0`
- 未配置 `secondaryTriggerOffset` 时，`openHeaderSecondary` 为空操作（不进入二楼）
- 手势拉过 `actualSecondaryTriggerOffset` 再松开，进入 `secondaryReady` 或 `secondaryOpen`（以测试里稳定能等到的模式为准）

`processedDuration: Duration.zero`，显式 `pump`。测试失败时只修被测路径（裁剪、`animateToOffset`、二楼模式表），不顺手改摩擦曲线。

### 4. 文档加两节，不改 sidebar

中英文 `docs/ui/refresh.md` / `docs/en/ui/refresh.md`：

- 「更多能力」补横向一行，并把原来的二楼一行改成指向新小节
- 新增「横向」：`ListView` / `PageView`、`triggerAxis`、PageView 须 `infiniteOffset: null`、`clipBehavior`
- 新增「二楼」：四个参数、状态机、`clipBehavior` + locator、与 `infiniteOffset` 互斥、返回键 / `closeHeaderSecondary`

不改 VitePress sidebar。不改 `FastRefreshChildBuilder` 默认示例（上一轮已定为 AppBar 在外）。

### 5. 不加二楼包装器

- **选择**：示例直接写 `FastSecondaryBuilderHeader` + Stack。
- **原因**：proposal 要求改动小、不新增 API。EasyRefresh 也没有包装器。
- **备选**：`FastSecondaryPageHeader`——会变成新能力，另开 change。

## Risks / Trade-offs

- [横拖 Widget 测试 flaky] → 断言轴与模式用 `startGesture` + 小步 `moveBy`；触发任务优先 `callRefresh` / `callLoad`，与 EasyRefresh 相同。
- [二楼手势测试不稳定] → 控制器开关作为必过用例；手势只断言能进二楼相关模式，不绑像素。
- [忘记 `clipBehavior: Clip.none` 会裁掉二楼 / 横轴指示器] → 两页 example 和文档都写死；测试不依赖视觉裁剪。
- [二楼 Stack 样板偏长] → 接受，本轮不加包装器。
- [入口从六页变八页] → 仍比 EasyRefresh Sample 少；Footer 二楼 / reverse 继续不做。

## Migration Plan

无公开 API 变更，调用方不用改代码。发布后在 `CHANGELOG.md` 记为 example / 文档 / 测试增强。回退即还原上述目录与文档提交。

## Open Questions

无。横向覆盖 `ListView` + 同页可切 `PageView`；二楼只做 Header，无 Rive、无包装器。
