import 'package:flutter/material.dart';

import 'fast_toast_config.dart';
import 'fast_toast_controller.dart';
import 'fast_toast_queue.dart';

/// Shows a themed text toast, or custom overlay content when [builder] is set.
/// 展示主题化文本 Toast；传入 [builder] 时改为自定义内容。
///
/// Does not require a [BuildContext]. Mount [FastToastOverlay] from
/// [MaterialApp.builder] first.
/// 无需 [BuildContext]。需先在 [MaterialApp.builder] 中挂载 [FastToastOverlay]。
///
/// When [builder] is set, it supplies overlay content and [message] is ignored.
/// The host still owns queue, position, duration, and motion.
/// 传入 [builder] 时由回调提供内容，并忽略 [message]；队列、位置、时长与动画仍由宿主管。
void showToast(
  String? message, {
  WidgetBuilder? builder,
  FastToastConfig? config,
}) {
  assert(
    builder != null || message != null,
    'showToast requires a message or a builder.',
  );
  final FastToastConfig resolved = config ?? const FastToastConfig();
  FastToastController.instance.enqueue(
    builder != null
        ? FastToastRequest.custom(builder, config: resolved)
        : FastToastRequest.text(message ?? '', config: resolved),
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
