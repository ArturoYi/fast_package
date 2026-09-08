## Why

`fast_package` 还没有列表刷新/加载组件。业务页若直接依赖 `easy_refresh`，会带上二楼、嵌套滚动、多皮肤和分页等远超「下拉刷新 + 上拉加载」的体积。需要一个只依赖 Flutter SDK、API 显式、手感对齐 EasyRefresh 核心协议的 `FastRefresh`。

## What Changes

- 新增 `FastRefresh`：包裹垂直滚动子树，提供下拉刷新与上拉/触底加载。
- 新增 `FastRefreshController`：编程触发与结束任务（`callRefresh` / `callLoad` / `finishRefresh` / `finishLoad` / `resetFooter`）。
- 新增 Classic 指示器（`FastClassicHeader` / `FastClassicFooter`）以及 Builder 指示器供自定义与测试。
- 新增自定义 `ScrollPhysics` + `ScrollBehavior`，用越界距离驱动状态机；不引入第三方依赖。
- 补充单元测试、example 演示页、中英文文档与 CHANGELOG。
- 第一版不做：二楼、NestedScrollView、横向、`FastRefresh.builder`、`refreshOnStart`、Locator/Listener、多皮肤、分页状态机。

## Capabilities

### New Capabilities

- `fast-refresh`: 垂直列表的下拉刷新、上拉/触底加载、任务结果与控制器协议。

### Modified Capabilities

- （无）仓库尚无主 specs。

## Impact

- `lib/src/ui_kit/fast_refresh/`：新模块；`lib/fast_package.dart` 导出公开 API。
- `test/fast_refresh_test/`：Widget 测试。
- `example/`：演示页与路由。
- `docs/ui/refresh.md`、`docs/en/ui/refresh.md`、VitePress sidebar、`CHANGELOG.md`。
- 依赖仍仅为 Flutter SDK。
