## Why

`fast_package` 目前没有全局 Toast。业务层（尤其是无 `BuildContext` 的回调 / 异步完成处）只能用 `SnackBar`，会随页面 pop 消失、可能被 Dialog 挡住，且多条消息容易重叠。需要一套与现有 UI Kit 风格一致、零第三方依赖、API 尽量少的 Overlay Toast。

## What Changes

- 对外只暴露两个展示方法：`showToast`（纯文本）与 `showCustomToast`（自定义 Widget）；调用方无需 `BuildContext`，也**没有** `success` / `error` / `info` / `custom` 等 type。
- 新增 `FastToastOverlay`，在 `MaterialApp.builder` 挂载一次，将 Toast 插入独立 Overlay，与 Navigator 栈解耦。
- 内存 FIFO 队列 + 单槽展示：同一时刻只显示一条，上一条退场后再播下一条；队列有上限，满时丢弃最旧 pending。
- `showToast` 使用主题化默认文本面板；`showCustomToast` 在相同队列 / 位置 / 动画下插入调用方 Widget。
- 支持时长、位置（上 / 中 / 下）、可选点击关闭；提供 `dismiss` / `dismissAll`。
- 新增 `FastToastTheme`（`ThemeExtension`），只服务默认文本面板，与 `FastShimmerTheme` 一样走主题解析。
- 补充中英文档、example 演示页、单元 / Widget 测试，并从 `lib/fast_package.dart` 导出。
- **不做**：type 枚举与三态便捷方法、双 Overlay 层、高优插队、Loading 暂停钩子、自定义动画枚举、进度 Toast。

## Capabilities

### New Capabilities

- `fast-toast`: 根 Overlay 上的全局 Toast：`showToast` / `showCustomToast`、FIFO 单槽队列、默认文本主题、入出场动画、可访问性与点击穿透。

### Modified Capabilities

- （无现有 spec）

## Impact

- 代码：新增 `lib/src/ui_kit/fast_toast/`；`lib/fast_package.dart` 增加 export；`example/` 增加 Toast 演示页并在 `MaterialApp.builder` 挂载 Overlay。
- 文档：`docs/ui/toast.md`、`docs/en/ui/toast.md`，侧栏与（如需要）首页能力列表。
- 测试：`test/fast_toast_test/`。
- 依赖：仅 Flutter SDK，不引入第三方包。
- 版本：`CHANGELOG` 记入新增 UI 组件（建议 `0.0.5`）。
- 无 **BREAKING** 变更；未挂载 `FastToastOverlay` 时调用应安全空操作（入队但不崩溃）。
