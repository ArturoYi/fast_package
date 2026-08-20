## Context

`fast_package` 是零第三方依赖的 Flutter 工具包。现有 UI Kit（`FastShimmer`、`GradientBoxBorders`）以 `lib/src/ui_kit/` + `ThemeExtension` + 文档站点 + example 页为固定形态。包内没有全局 Toast。

参考实现 `barrel_lock/packages/fast_toast` 已验证 Overlay + FIFO 单槽可用，但面向 BarrelLock 业务：type 三态、双 Overlay 层、Loading 暂停、高优插队。本设计只保留其核心调度，公开 API 收成两个方法：`showToast` 与 `showCustomToast`。

约束：仅 Flutter SDK；公开展示入口不带 type；与 `FastShimmerTheme` 一样用 `ThemeExtension`（仅默认文本面板）；中英文档与 example 同步。

## Goals / Non-Goals

**Goals:**

- 在 `MaterialApp.builder` 挂载一次后，任意处调用 `showToast` / `showCustomToast`，无需 `BuildContext`。
- Toast 挂在独立 Overlay 上，不随当前路由 pop 消失，也不挡住路由手势。
- 同一时刻只展示一条；多条消息 FIFO 排队；两种入口共用同一条队列。
- `showToast` 的默认视觉可通过 `FastToastTheme` 全局定制；`showCustomToast` 由调用方完全控制内容外观。
- 文件、导出、测试、文档、example 对齐现有 UI Kit 惯例。

**Non-Goals:**

- `FastToastType` 以及 `success` / `error` / `info` / `custom` 便捷方法。
- 双层 Overlay（normal / elevated）及 `overlayLayerResolver`。
- 与 Loading 协作（`loadingPauseCheck` / `resume` / `bypassLoadingPause`）。
- 高优先级插队打断当前条。
- 可切换的动画枚举、进度 Toast。
- 独立 package；能力内嵌于 `fast_package`。

## Decisions

### 1. Overlay 挂载，而不是 SnackBar

- **选择**：`FastToastOverlay` 在 `MaterialApp.builder` 用 `Stack(child + Overlay)` 提供独立 `OverlayState`，单例 controller 向其插入 `OverlayEntry`。
- **理由**：无 Context、与 Navigator 解耦、可盖在 Dialog 上；接入成本只是 builder 包一层。
- **备选**：`ScaffoldMessenger.showSnackBar` — 需要 Scaffold 祖先，页面 pop 会丢；`navigatorKey.currentState.overlay` — 与路由框架耦合。均不采用。
- **未挂载**：`showToast` / `showCustomToast` 只入队、不抛异常；`attach` 后继续 dequeue。文档明确要求业务 App 挂载 Overlay。

### 2. 单 Overlay、无层级 / 优先级 / Loading 钩子

- **选择**：一个 `OverlayState`、一个 `OverlayEntry` 槽。去掉 elevated host、priority、loading pause。
- **理由**：本包没有 Loading / 锁屏；双层与插队会让队列语义难测。需要盖住全屏遮罩时，由消费方把 `FastToastOverlay` 挂在更高 builder 即可。
- **备选**：完整移植参考实现 — 拒绝，违反「简洁」。

### 3. 队列：FIFO + 上限 5 + drop-oldest

- **选择**：pending 最多 5 条（不含当前展示）；满时丢掉最旧 pending，再追加新条。当前条不受影响。`showToast` 与 `showCustomToast` 入同一队列。
- **理由**：防止异步风暴撑爆内存；drop-oldest 保留最新反馈。
- **默认时长**：2000ms；到期播退场动画后再 dequeue。`FastToast.dismiss()` 关当前条并续播；`FastToast.dismissAll()` 清队列并立刻移除当前 Entry（无退场）。

### 4. 公开 API 只有两个展示入口

```dart
void showToast(String message, {FastToastConfig? config});

void showCustomToast(Widget toast, {FastToastConfig? config});

abstract final class FastToast {
  static bool get isShowing;
  static int get pendingCount;
  static void dismiss();
  static void dismissAll();
}

enum FastToastPosition { top, center, bottom }

final class FastToastConfig {
  const FastToastConfig({
    this.duration = const Duration(milliseconds: 2000),
    this.position = FastToastPosition.center,
    this.dismissible = false,
  });
}
```

- **选择**：顶层函数 `showToast` / `showCustomToast` 为唯一展示 API；生命周期仍挂在 `FastToast` 上。不导出 type，不提供 `success`/`error`/`info`。
- **`showToast`**：包内用 `FastToastTheme` 渲染圆角文本面板（无内置图标）。
- **`showCustomToast`**：调用方传入的 `Widget` 作为 Toast 内容；宿主仍负责队列、位置、时长、入出场动画与区域外点击穿透，**不**再套默认背景/内边距。Widget 构建在 Overlay 子树中，可用 `Builder` / `Theme.of`。
- **位置**：enum，top/bottom 在 `viewPadding` 之外再加 24（合成层平移）；不提供自定义 offset。键盘 `viewInsets` 只改合成层矩阵，不 rebuild / relayout Toast。
- **理由**：业务要成功/失败态时自己在 `showCustomToast` 里放图标；包不预设语义。
- **备选**：`FastToast.show` + type — 用户已明确拒绝。

### 5. 视觉走 `FastToastTheme`，只作用于 `showToast`

- **选择**：`ThemeExtension<FastToastTheme>`，含背景色、文字样式、圆角、内边距、投影。`light` / `dark` 静态默认值（含各自投影）。不含 type 图标色。
- **解析顺序**：1) `FastToastConfig` 行为字段；2) `ThemeData.extensions`；3) 按 `brightness` 回退 `light`/`dark`。
- **`showCustomToast`**：不读取面板主题来包裹内容；主题若要作用，由调用方 Widget 自行读取。

### 6. 目录与导出

```
lib/src/ui_kit/fast_toast/
  fast_toast.dart                 # showToast / showCustomToast / FastToast（导出）
  fast_toast_overlay.dart         # 根挂载 Widget（导出）
  fast_toast_theme.dart           # ThemeExtension（导出）
  fast_toast_config.dart          # FastToastConfig（导出）
  fast_toast_position.dart        # FastToastPosition（导出）
  fast_toast_controller.dart      # 单例调度（不导出）
  fast_toast_queue.dart           # FIFO（不导出）
  widgets/fast_toast_view.dart    # 默认文本面板 + fade/slide（不导出）
```

`lib/fast_package.dart` 只 export 上列五个公开文件。不存在 `fast_toast_type.dart`。Controller / queue / view 保持库内实现。

### 7. 动画、命中与无障碍

- 入出场固定 200ms：`FadeTransition` + 按位置方向的轻微 `SlideTransition`（top 从上、bottom 从下、center 仅 fade）。两种展示入口共用。
- Toast 区域外不拦截命中（`Align` 空白不 hit test）；`dismissible: true` 时仅内容区域可点关闭。
- 安全区与键盘避让由内部 `FastToastKeyboardShift` 在合成层完成：`didChangeMetrics` 只 `markNeedsCompositedLayerUpdate`。
- `showToast`：`Semantics(liveRegion: true, label: message)`。
- `showCustomToast`：不强制覆盖子树 semantics；调用方负责无障碍标签。
- Entry 移除前必须 `dispose` `AnimationController`。

### 8. 测试与文档

- `test/fast_toast_test/`：队列 FIFO / 上限、controller 单槽与 dismiss、`showToast` 文案与到期消失、`showCustomToast` 能找到自定义 Widget、未挂载不抛错。
- 文档对齐 `docs/ui/shimmer.md`：概览表、builder 接入、`showToast` / `showCustomToast` 示例、主题注册、非目标。英文镜像 `docs/en/ui/toast.md`。
- example：`MaterialApp.builder` 包裹 `FastToastOverlay`，演示文本 Toast 与自定义 Toast。

## Risks / Trade-offs

- [未挂载 Overlay 时调用无可见效果] → 入队不抛错；文档与 example 把 builder 接入放在第一段；测试覆盖「不崩溃」。
- [热重启 / Overlay dispose 丢当前条] → `detach` 立刻移除 Entry、保留 pending；重新 `attach` 后继续 dequeue。
- [单槽排队使后一条晚于前面的 Toast] → 接受；需要立刻覆盖时调用方 `dismissAll()` 再 `showToast`。不做隐式插队。
- [自定义 Widget 持有错误 Context] → 内容插入 Overlay 子树；文档说明用传入的 Widget 自身 `build`，不要捕获已销毁的页面 context。
- [独立 Overlay 可能盖住业务自定义 Overlay] → 文档说明把 `FastToastOverlay` 放在 builder 最外层或按需调整包裹顺序。

## Migration Plan

- 纯新增 API，无破坏性变更。
- 消费方：升级依赖 → `MaterialApp.builder` 包 `FastToastOverlay` → 调用 `showToast` / `showCustomToast`。
- 回滚：去掉 Overlay 包裹与调用即可，不影响现有组件。
- 版本建议：`pubspec.yaml` `0.0.5`，`CHANGELOG.md` 记录 Toast。

## Open Questions

无。默认时长 2000ms、位置 center、队列上限 5、顶层 `showToast` / `showCustomToast`、无 type，均已拍板。
