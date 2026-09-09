## Context

`FastRefresh` 已实现 EasyRefresh 核心协议：`FastRefresh` / `FastRefresh.builder`、Locator、`refreshOnStart`、`clamping`、`isNested`、Footer 完成后重算 offset。example 只有 Widget / Builder 两页普通列表；测试集中在 `callRefresh` / `callLoad` / `noMore` / 互斥；文档与 `FastRefreshChildBuilder` 注释仍把 `SliverAppBar` 写进 builder 第一例，刷新会从屏幕顶开始。

本轮只覆盖已有 API，不扩内核。对照仓库是本机 `flutter_easy_refresh-3`，用来抄场景结构，不引入其皮肤或 paging 包。

## Goals / Non-Goals

**Goals:**

- Refresh example 变成六页矩阵：现有 Widget / Builder，加上 Nested、Locator、`refreshOnStart`、clamping。
- 默认页（Widget / Builder）AppBar 在 `FastRefresh` 外，刷新发生在列表区。
- 测试覆盖 Nested、Locator、`refreshOnStart`、Footer 完成同步。
- 中英文文档与 builder 注释的第一例改为 AppBar 在外；折叠顶栏指向 Nested / Locator。

**Non-Goals:**

- Material / Cupertino / Bezier 等皮肤。
- `FastPaging`、`FastRefreshTheme`、无障碍 Semantics。
- 二楼、横向、`reverse`、Listener、TabBarView / PageView 示例。
- 重写 physics / 状态机，或把 `part of` 拆成独立库。
- 整页移植 EasyRefresh example（GetX、多皮肤橱窗）。

## Decisions

### 1. 示例用入口 push，不加 named route

- **选择**：沿用现有 `RefreshExample` 的 `Navigator.push` + 分目录页面。
- **原因**：Widget / Builder 已经这样组织；六页仍是「Refresh 子系统」，不必改 `ExampleRoute`。
- **备选**：每页一个 named route——和 debounce / toast 的扁平路由不一致，且入口已能到达。

目录：

```
example/lib/pages/refresh_example/
  refresh_example.dart
  widget/refresh_widget_example.dart      # 已有
  builder/refresh_builder_example.dart    # 已有，AppBar 在外
  nested/refresh_nested_example.dart
  locator/refresh_locator_example.dart
  refresh_on_start/refresh_on_start_example.dart
  clamping/refresh_clamping_example.dart
```

### 2. 四页场景怎么挂 FastRefresh

| 页 | 构造 | 要点 |
| --- | --- | --- |
| Nested | `FastRefresh.builder` + `isNested: true` | 外层 `SliverAppBar`，`physics` 挂内层列表；`scrollController` 绑可滚动层 |
| Locator | `FastRefresh.builder` | Header/Footer `position: locator`，sliver 里插 `FastHeaderLocator.sliver` / `FastFooterLocator.sliver`；可用 `Scaffold.appBar` 或短 `SliverToBoxAdapter` 说明，不要再用「未 locator 的 SliverAppBar + Stack Header」 |
| refreshOnStart | `FastRefresh` Widget 构造 | `refreshOnStart: true`，可选 `refreshOnStartHeader`；AppBar 在外 |
| clamping | `FastRefresh` Widget 构造 | `FastClassicHeader(clamping: true)`；AppBar 在外 |

共用现有 example 的假分页（约 20 条、最多 3 页、`controlFinish*`），避免再发明一套数据层。

### 3. 测试按场景拆文件，不改主路径文件行为

- **选择**：保留 `test/fast_refresh_test/fast_refresh_test.dart`，新增：
  - `fast_refresh_nested_test.dart`
  - `fast_refresh_locator_test.dart`
  - `fast_refresh_on_start_test.dart`
  - `fast_refresh_completion_sync_test.dart`
- **原因**：主文件已有 12 条主路径；完成同步需要「加载中途加长列表」，和现有 harness 绑在一起会变脆。EasyRefresh 也是按场景分文件。
- **备选**：全部塞进一个文件——难复用、难对照失败。

完成同步对齐 EasyRefresh `indicator_completion_sync_test`：`controlFinishLoad` + `processedDuration: Duration.zero`，先触底加载，再 `setState` 加长，再 `finishLoad`，断言 footer `inactive` 且 `offset == 0`。

内核已有 `_syncFooterOffsetAfterProcessed`。测试失败时只修这条同步，不顺手改物理。

### 4. 文档第一例去掉 SliverAppBar

三处一起改，避免注释和站点打架：

1. `docs/ui/refresh.md` / `docs/en/ui/refresh.md` 的 builder 代码块
2. `lib/src/ui_kit/fast_refresh/builder/fast_refresh_builder.dart` 的 dartdoc
3. 「更多能力」里写清：折叠顶栏用 Nested 或 Locator；example 路径点名四页

不改 VitePress sidebar（仍是一篇 Refresh 文档）。

### 5. 不在本轮加皮肤或主题

- **选择**：Classic 继续当唯一默认皮肤；颜色 / 文案仍由页面传入。
- **原因**：本轮目标是「已有 API 能被看见、被测到」。Material / Cupertino 是新模块，应另开 change。
- **备选**：顺手加 `FastMaterialHeader`——会把范围拉回多皮肤，和 proposal 冲突。

## Risks / Trade-offs

- [Nested 手感与 EasyRefresh 不完全一致] → example 只保证 `isNested: true` 能刷、指示器在内层列表区；不承诺像素级对齐。
- [Locator + AppBar 组合仍可能让人困惑] → Locator 页用短文案说明「指示器在 sliver 里」；折叠顶栏以 Nested 页为准。
- [完成同步测试 flaky] → 固定 `processedDuration: Duration.zero`、显式 `pump` 帧；必要时只修 `_syncFooterOffsetAfterProcessed`。
- [example 入口变长] → 六页仍比 EasyRefresh Sample 少；二楼 / 横向 / 聊天留到以后。
- [文档与 example 再次分叉] → 三处默认示例同一结构：`Scaffold.appBar` + `CustomScrollView(physics: physics)`。

## Migration Plan

无公开 API 变更，调用方不用改代码。发布后在 `CHANGELOG.md` 记为 example / 文档 / 测试增强。回退即还原上述目录与文档提交。

## Open Questions

无。范围已按建议收成：示例矩阵、四类回归、文档默认布局。皮肤、分页、主题另开 change。
