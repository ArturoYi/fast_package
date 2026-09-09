## 1. 示例矩阵

- [x] 1.1 新增 `nested/refresh_nested_example.dart`：`FastRefresh.builder` + `isNested: true` + `NestedScrollView`，外层钉 AppBar，physics 挂内层列表
- [x] 1.2 新增 `locator/refresh_locator_example.dart`：Header/Footer `position: locator`，在 sliver 里插入 `FastHeaderLocator.sliver` / `FastFooterLocator.sliver`
- [x] 1.3 新增 `refresh_on_start/refresh_on_start_example.dart`：`refreshOnStart: true`，AppBar 在外，结束后仍可手动 `callRefresh`
- [x] 1.4 新增 `clamping/refresh_clamping_example.dart`：`FastClassicHeader(clamping: true)`，AppBar 在外
- [x] 1.5 更新 `refresh_example.dart` 入口，列出 Widget、Builder、Nested、Locator、refreshOnStart、clamping
- [x] 1.6 确认 Widget / Builder 两页仍把 `Scaffold.appBar` 放在 `FastRefresh` 外面

## 2. 回归测试

- [x] 2.1 新增 `fast_refresh_nested_test.dart`：`isNested: true` + `NestedScrollView` 能挂载；`callRefresh` 会跑 `onRefresh`
- [x] 2.2 新增 `fast_refresh_locator_test.dart`：列表里有 locator sliver；刷新时 Header 状态经 locator 更新
- [x] 2.3 新增 `fast_refresh_on_start_test.dart`：首帧自动刷新一次；之后仍可 `callRefresh`
- [x] 2.4 新增 `fast_refresh_completion_sync_test.dart`：加载中把列表加长离开越界，结束后 Footer 为 `inactive` 且 offset 为 `0`
- [x] 2.5 若完成同步失败，只修 `_syncFooterOffsetAfterProcessed`（或同等最小路径）
- [x] 2.6 跑 `flutter test test/fast_refresh_test`，现有 `fast_refresh_test.dart` 必须通过

## 3. 文档与变更记录

- [x] 3.1 重写 `docs/ui/refresh.md` 与 `docs/en/ui/refresh.md` 的 builder 第一例：`Scaffold.appBar` + 只含列表的 `CustomScrollView`；折叠顶栏指向 Nested / Locator
- [x] 3.2 把 `FastRefreshChildBuilder` 的 dartdoc 改成同一套默认示例
- [x] 3.3 在文档「更多能力」/ More 里点名新增的四页 example
- [x] 3.4 更新 `CHANGELOG.md`
