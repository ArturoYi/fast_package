import 'fast_toast_position.dart';

/// Per-toast behavior for [showToast] and [showCustomToast].
/// [showToast] 与 [showCustomToast] 的单条行为配置。
final class FastToastConfig {
  /// Creates a toast behavior config.
  /// 创建一条 Toast 的行为配置。
  const FastToastConfig({
    this.duration = const Duration(milliseconds: 2000),
    this.position = FastToastPosition.center,
    this.dismissible = false,
  });

  /// How long the toast stays visible before exit animation.
  /// Toast 在退场动画前保持可见的时长。
  final Duration duration;

  /// Where the toast is aligned on screen.
  /// Toast 在屏幕上的对齐位置。
  final FastToastPosition position;

  /// Whether tapping the toast content dismisses it.
  /// 点击 Toast 内容是否关闭当前条。
  final bool dismissible;
}
