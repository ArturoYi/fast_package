## 1. 示例

- [x] 1.1 新增 `horizontal/refresh_horizontal_example.dart`：横向 `ListView`，AppBar 在外，`clipBehavior: Clip.none`；AppBar 可切到 `PageView`，此时 Footer `infiniteOffset: null`
- [x] 1.2 新增 `secondary/refresh_secondary_example.dart`：`FastSecondaryBuilderHeader` + locator Classic Header，`clipBehavior: Clip.none`，纯色二楼页，`listenable` 同步 AppBar，`openHeaderSecondary` / `closeHeaderSecondary` / `PopScope`
- [x] 1.3 更新 `refresh_example.dart` 入口，在现有六页后列出横向、二楼

## 2. 回归测试

- [x] 2.1 新增 `fast_refresh_horizontal_test.dart`：横向 `ListView` 挂载；横拖后 Header `axis` 为 horizontal 且模式非 `inactive`；`callRefresh` / `callLoad` 能跑回调
- [x] 2.2 新增 `fast_refresh_secondary_test.dart`：`openHeaderSecondary` → `secondaryOpen`；`closeHeaderSecondary` → `inactive` 且 offset 为 `0`；未配置 `secondaryTriggerOffset` 时打开为空操作；手势过二楼阈值进入 `secondaryReady` 或 `secondaryOpen`
- [x] 2.3 若横向或二楼测试失败，只修被测路径（裁剪、`animateToOffset`、二楼模式表），不改摩擦曲线
- [x] 2.4 跑 `flutter test test/fast_refresh_test`，现有主路径与上一轮场景测试必须通过

## 3. 文档与变更记录

- [x] 3.1 在 `docs/ui/refresh.md` 与 `docs/en/ui/refresh.md` 增加横向、二楼小节（参数、`clipBehavior`、PageView 关无限加载、与 `infiniteOffset` 互斥），并指向新 example
- [x] 3.2 更新「更多能力」/ More，点名横向与二楼两页
- [x] 3.3 更新 `CHANGELOG.md`
