## 1. 领域模型与队列

- [x] 1.1 新增 `lib/src/ui_kit/fast_toast/fast_toast_position.dart`（`top` / `center` / `bottom`）
- [x] 1.2 新增 `fast_toast_config.dart`（默认 duration 2000ms、position center、dismissible false）
- [x] 1.3 新增内部 `fast_toast_queue.dart`：FIFO、pending 上限 5、满时 drop-oldest、`clear`；请求同时支持文本与自定义 Widget

## 2. 主题与展示

- [x] 2.1 新增 `fast_toast_theme.dart`：`ThemeExtension`（背景、文字、圆角、内边距、投影）、`light`/`dark` 默认、`of`/`resolve`/`copyWith`/`lerp`（对齐 `FastShimmerTheme`）；不含 type / 图标色
- [x] 2.2 新增 `widgets/fast_toast_view.dart`：`showToast` 用主题化文本面板；`showCustomToast` 原样放入内容；共用 fade（center）或 fade+slide（top/bottom）、200ms 入出场；区域外点击穿透；`dismissible` 点击关闭；文本 Toast 带 `Semantics(liveRegion)`；退场用 AnimationStatus；键盘避让走合成层

## 3. Overlay 调度与公开 API

- [x] 3.1 新增内部 `fast_toast_controller.dart`：单例 attach/detach、单槽 show、到期/dismiss 后退场再 dequeue、`dismissAll` 立即清场、未 attach 时只入队不抛错；`showToast` 与 `showCustomToast` 共用队列
- [x] 3.2 新增 `fast_toast_overlay.dart`：`Stack(child + Overlay)`，首帧注册 `OverlayState`，dispose 时 detach
- [x] 3.3 新增 `fast_toast.dart`：顶层 `showToast` / `showCustomToast`；`FastToast.dismiss` / `dismissAll` / `isShowing` / `pendingCount`。不提供 type 与 `success`/`error`/`info`
- [x] 3.4 在 `lib/fast_package.dart` 导出公开 API，不导出 queue / controller / view，不导出 type

## 4. 测试

- [x] 4.1 `test/fast_toast_test/` 队列：FIFO、上限 5 drop-oldest、clear、文本与自定义请求混排
- [x] 4.2 Controller：单槽串行、dismiss 续播、dismissAll、未挂载不抛错、detach 保留 pending
- [x] 4.3 Widget：`showToast` 文案可见且到期消失；`showCustomToast` 能找到自定义 Widget 且无默认面板包裹；`dismissible` 点击关闭；主题 extension 仅影响文本 Toast

## 5. Example、文档与版本

- [x] 5.1 `example/lib/main.dart` 的 `MaterialApp.builder` 包裹 `FastToastOverlay`；新增 Toast 示例页（文本 + 自定义）并挂到 index / routes
- [x] 5.2 写 `docs/ui/toast.md` 与 `docs/en/ui/toast.md`（概览、builder 接入、`showToast` / `showCustomToast`、主题、非目标），并更新 VitePress 中英文侧栏
- [x] 5.3 将 `pubspec.yaml` 版本改为 `0.0.5`，更新 `CHANGELOG.md`
- [x] 5.4 运行 `flutter analyze` 与 `flutter test`，确认通过
