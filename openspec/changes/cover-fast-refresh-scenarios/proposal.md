## Why

`FastRefresh` 的内核已对齐 EasyRefresh 协议（builder、locator、`refreshOnStart`、`clamping`、`isNested` 都在），但 example 只有普通列表两页，测试只覆盖主路径，文档还把 `SliverAppBar` 写进 builder 第一例。用户会误以为「只有下拉刷新」，或把刷新锚点钉到屏幕顶。先补齐已有 API 的场景、回归和文档，不扩皮肤与分页。

## What Changes

- 扩展 Refresh example 入口：在现有 Widget / Builder 两页之外，增加 Nested、Locator、`refreshOnStart`、clamping 四页；AppBar 放在 `FastRefresh` 外面（Nested 用外层钉顶栏）。
- 补 Widget 测试：Footer 完成同步、`isNested`、Locator、`refreshOnStart`。
- 修正中英文文档与 `FastRefreshChildBuilder` 注释：builder 默认示例改为 `Scaffold.appBar` + 下方 `CustomScrollView`；折叠顶栏指向 Nested / Locator，不再当第一例。
- 更新 `CHANGELOG.md`。
- 不新增公开 API，不改状态机 / physics。
- 本轮不做：Material / Cupertino 皮肤、`FastPaging`、`FastRefreshTheme`、二楼 / 横向 / reverse / Listener 示例。

## Capabilities

### New Capabilities

- （无）本轮不引入新能力，只覆盖已有 `fast-refresh`。

### Modified Capabilities

- `fast-refresh`：补上已实现但未写进需求的场景覆盖（Nested、Locator、`refreshOnStart`、clamping）、Footer 完成同步，以及 example / 文档的默认布局约定。

## Impact

- `example/lib/pages/refresh_example/`：入口增加四页；现有 Widget / Builder 页保持 AppBar 在外。
- `example/lib/routes/routes.dart`：仅当新页需要独立 named route 时改；默认可从 Refresh 入口 `push`。
- `test/fast_refresh_test/`：新增或拆分回归用例。
- `docs/ui/refresh.md`、`docs/en/ui/refresh.md`、`lib/src/ui_kit/fast_refresh/builder/fast_refresh_builder.dart`：默认示例与场景说明。
- `CHANGELOG.md`。
- `lib/src/ui_kit/fast_refresh/` 内核原则上只改注释；发现完成同步等缺陷时允许最小修复。
- 依赖仍仅为 Flutter SDK。
