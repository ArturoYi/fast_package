import 'package:flutter/material.dart';

import 'fast_loading_config.dart';
import 'fast_loading_controller.dart';
import 'fast_loading_request.dart';

/// Shows a themed centered loading overlay. Does not require a [BuildContext].
/// 展示主题化居中 Loading，无需 [BuildContext]。
///
/// Mount [FastLoadingOverlay] from [MaterialApp.builder] first.
/// 需先在 [MaterialApp.builder] 中挂载 [FastLoadingOverlay]。
///
/// Stays until [FastLoading.dismiss]. A later call replaces the current overlay.
/// 会一直显示到 [FastLoading.dismiss]；再次调用会替换当前条。
///
/// When [builder] is set, it supplies overlay content and [message] is ignored.
/// The host still owns centering, fade, and the barrier.
/// 传入 [builder] 时由回调提供内容，并忽略 [message]；居中、淡入淡出与遮罩仍由宿主管。
void showLoading({
  String? message,
  WidgetBuilder? builder,
  FastLoadingConfig? config,
}) {
  final FastLoadingConfig resolved = config ?? const FastLoadingConfig();
  FastLoadingController.instance.show(
    builder != null
        ? FastLoadingRequest.custom(builder, config: resolved)
        : FastLoadingRequest.standard(message: message, config: resolved),
  );
}

/// Lifecycle controls for the global loading overlay.
/// 全局 Loading 的生命周期控制。
abstract final class FastLoading {
  static FastLoadingController get _controller => FastLoadingController.instance;

  /// Whether a loading overlay is currently on screen.
  /// 当前是否正在展示 Loading。
  static bool get isShowing => _controller.isShowing;

  /// Dismisses the current loading with exit animation; no-op when idle.
  /// 以退场动画关闭当前 Loading；空闲时清空 pending。
  static void dismiss() {
    _controller.dismiss();
  }

  /// Removes the current loading immediately and drops any pending request.
  /// 立即移除当前 Loading 并丢掉 pending。
  static void dismissNow() {
    _controller.dismissImmediate();
  }
}
