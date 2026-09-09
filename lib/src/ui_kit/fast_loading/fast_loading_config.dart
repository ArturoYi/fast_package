/// Per-loading behavior for [showLoading].
/// [showLoading] 的单次行为配置。
final class FastLoadingConfig {
  /// Creates a loading behavior config.
  /// 创建一次 Loading 的行为配置。
  const FastLoadingConfig({
    this.barrierDismissible = false,
    this.lockPop = true,
  });

  /// Whether tapping the barrier dismisses the loading overlay.
  /// 点击遮罩是否关闭 Loading。
  final bool barrierDismissible;

  /// Whether back navigation is blocked while this loading is visible.
  /// 本次 Loading 展示期间是否禁止返回。
  ///
  /// Needs [FastLoadingOverlay.navigatorKey] (same instance as
  /// [MaterialApp.navigatorKey]) to lock the current route.
  /// 需要 [FastLoadingOverlay.navigatorKey]（与 [MaterialApp.navigatorKey]
  /// 同一把）才能锁住当前路由。
  ///
  /// Direct [Navigator.pop] is not blocked.
  /// 直接调用 [Navigator.pop] 不会被拦住。
  final bool lockPop;
}
