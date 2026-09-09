## Why

`FastRefresh` 已具备横向轴与二楼内核（`triggerAxis`、横轴定位、`FastSecondaryBuilderHeader`、`openHeaderSecondary` / `closeHeaderSecondary`），但 example 只有竖列表六页，测试没有横拖 / 二楼状态机，文档对二楼只剩一行、横向完全没写。用户会以为这两项还没做，或自己去改 physics。`cover-fast-refresh-scenarios` 已收完，现在用最小覆盖把已有 API 暴露出来，不扩皮肤、不写便利包装器。

## What Changes

- Refresh 示例入口增加两页：横向 `ListView`（可切 `PageView`）、Header 二楼（locator + 简易二楼页，无 Rive）。
- 补 Widget 测试：横轴拖拽 / `callRefresh` / `callLoad`；二楼 `openHeaderSecondary` / `closeHeaderSecondary` / 手势过阈值。
- 中英文文档写清横向（`scrollDirection`、`triggerAxis`、PageView 须关 Footer 无限加载）和二楼配方（`clipBehavior`、locator、与 `infiniteOffset` 互斥、返回键关楼）。
- 更新 `CHANGELOG.md`。
- 不新增公开 API，不改状态机 / physics。
- 本轮不做：Footer 二楼示例、`FastSecondaryPageHeader` 包装器、`reverse`、Listener、皮肤、分页。

## Capabilities

### New Capabilities

- （无）本轮不引入新能力，只覆盖已有 `fast-refresh`。

### Modified Capabilities

- `fast-refresh`：补上已实现但未写进需求的横向刷新与 Header 二楼场景覆盖（example / 测试 / 文档）。

## Impact

- `example/lib/pages/refresh_example/`：入口从六页加到八页；新目录 `horizontal/`、`secondary/`。
- `example/lib/routes/routes.dart`：仅当新页需要独立 named route 时改；默认可从 Refresh 入口 `push`。
- `test/fast_refresh_test/`：新增横向与二楼回归用例。
- `docs/ui/refresh.md`、`docs/en/ui/refresh.md`：「更多能力」补横向与二楼，并加可抄代码块。
- `CHANGELOG.md`。
- `lib/src/ui_kit/fast_refresh/` 内核原则上只改注释；示例或测试摸到裁剪 / 回弹 / `secondaryDimension` 缺陷时允许最小修复。
- 依赖仍仅为 Flutter SDK。
