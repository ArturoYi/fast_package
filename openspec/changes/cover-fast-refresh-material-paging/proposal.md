## Why

FastRefresh 已经对齐 EasyRefresh 的物理与状态机，但日常接入还缺两块：没有「系统刷新」那种 Material 转圈皮肤，分页必须写一个 `FastPaging` 子类。Classic 文案只能逐页硬编码，`resetAfterRefresh` 与文档不符，`FastRefresh` 销毁后 controller 仍指向已 dispose 的 State。这些应一次规划、分步落地。

## What Changes

- 增加 `FastMaterialHeader` / `FastMaterialFooter`：SDK 内 `RefreshProgressIndicator` / `CircularProgressIndicator`，默认 `clamping: true`，不搬 Bezier / Phoenix 等皮肤。
- 增加 `FastPagingList<T>` + `FastPagingPage<T>`：传入 `fetchPage` 和 `itemBuilder` 即可分页，不必再继承 `FastPaging`。`FastPaging` 基类保留给要自定义 sliver 的人。
- 增加 `FastRefreshTheme`（`ThemeExtension`），Classic 文案 / 颜色与 Material 指示器颜色可走主题；解析顺序与 Toast / Loading / Shimmer 一致。
- 修正 `resetAfterRefresh`：仅在刷新**成功**时清 Footer `noMore`（含 `controlFinishRefresh` + `finishRefresh(success)`）。失败或 `noMore` 不再误清。这是与文档对齐的行为修复。
- `FastRefresh` dispose / 更换 controller 时解绑，避免拆页后再 `finishRefresh` / `callRefresh` 打到已销毁的 notifier。
- 默认 Header / Footer 仍是 Classic。不引入新依赖。不搬 EasyRefresh 其余皮肤，不上独立 localization delegate。

## Capabilities

### New Capabilities

- `fast-refresh`: Material 薄皮肤、FastPagingList、Refresh Theme，以及 `resetAfterRefresh` / controller 解绑的正确性要求。

### Modified Capabilities

- （无。主 specs 尚未收录 `fast-refresh`，本次以 change 内新能力规格描述增量行为。）

## Impact

- 库：`lib/src/ui_kit/fast_refresh/`（新 theme / material / paging list 文件，`part of` 挂入 `fast_refresh.dart`），`fast_refresh_widget.dart`、`fast_refresh_controller.dart`、Classic 指示器解析文案。
- 测试：`test/fast_refresh_test/` 增补 Theme、Material、PagingList、`resetAfterRefresh`、controller 解绑。
- 示例：example 刷新入口增加 Material 页；Paging 页增加 `FastPagingList` 用法。
- 文档：中英文 `docs/ui/refresh.md`、`CHANGELOG.md`、credits 改善说明。
- 依赖：仍仅 Flutter SDK。对外 API 只增不删；`resetAfterRefresh` 在失败路径上的行为会与旧实现不同。
