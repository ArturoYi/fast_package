import 'package:flutter/material.dart';

import 'fast_toast_config.dart';
import 'fast_toast_controller.dart';
import 'fast_toast_queue.dart';

/// Shows a themed text toast. Does not require a [BuildContext].
/// 展示主题化文本 Toast，无需 [BuildContext]。
///
/// Mount [FastToastOverlay] from [MaterialApp.builder] first.
/// 需先在 [MaterialApp.builder] 中挂载 [FastToastOverlay]。
void showToast(String message, {FastToastConfig? config}) {
  FastToastController.instance.enqueue(
    FastToastRequest.text(
      message,
      config: config ?? const FastToastConfig(),
    ),
  );
}

/// Shows [toast] as overlay content without default panel chrome.
/// 将 [toast] 作为 Overlay 内容展示，不套默认面板。
///
/// Queue, position, duration, and motion are still handled by the host.
/// 队列、位置、时长与动画仍由宿主管。
void showCustomToast(Widget toast, {FastToastConfig? config}) {
  FastToastController.instance.enqueue(
    FastToastRequest.custom(
      toast,
      config: config ?? const FastToastConfig(),
    ),
  );
}

/// Lifecycle controls for the global toast queue.
/// 全局 Toast 队列的生命周期控制。
abstract final class FastToast {
  static FastToastController get _controller => FastToastController.instance;

  /// Whether a toast is currently on screen.
  /// 当前是否正在展示 Toast。
  static bool get isShowing => _controller.isShowing;

  /// Pending queue length, excluding the visible toast.
  /// 待展示队列长度（不含当前条）。
  static int get pendingCount => _controller.pendingCount;

  /// Dismisses the current toast with exit animation; no-op when idle.
  /// 以退场动画关闭当前条；空闲时为空操作。
  static void dismiss() {
    _controller.dismiss();
  }

  /// Clears the queue and removes the current toast immediately.
  /// 清空队列并立即移除当前 Toast。
  static void dismissAll() {
    _controller.dismissAll();
  }
}
