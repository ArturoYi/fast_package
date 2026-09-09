import 'package:flutter/material.dart';

import 'fast_loading_controller.dart';

/// Host widget mounted from [MaterialApp.builder] to provide a loading overlay.
/// 挂在 [MaterialApp.builder] 上、为 Loading 提供 Overlay 的宿主。
///
/// Nest outside [FastToastOverlay] so loading sits above toasts:
/// 包在 [FastToastOverlay] 外侧，让 Loading 盖在 Toast 之上：
///
/// ```dart
/// final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
///
/// MaterialApp(
///   navigatorKey: rootNavigatorKey,
///   builder: (context, child) {
///     return FastLoadingOverlay(
///       navigatorKey: rootNavigatorKey,
///       child: FastToastOverlay(
///         child: child ?? const SizedBox.shrink(),
///       ),
///     );
///   },
/// )
/// ```
///
/// Pass the same [navigatorKey] as [MaterialApp.navigatorKey] to block
/// [Navigator.maybePop], the AppBar back button, iOS swipe-back, and the
/// system back button while loading is visible.
/// 与 [MaterialApp.navigatorKey] 传入同一把 key，即可在 Loading 展示时
/// 拦住 [Navigator.maybePop]、AppBar 返回、iOS 侧滑和系统返回键。
class FastLoadingOverlay extends StatefulWidget {
  /// Wraps [child] and registers an [Overlay] with the loading controller.
  /// 包裹 [child]，并向 Loading 调度器注册 [Overlay]。
  const FastLoadingOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  /// The app subtree under the loading overlay.
  /// Overlay 下方的应用子树。
  final Widget child;

  /// Root navigator used to lock the current route against pops.
  /// 用于锁定当前路由、禁止返回的根 Navigator。
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<FastLoadingOverlay> createState() => _FastLoadingOverlayState();
}

class _FastLoadingOverlayState extends State<FastLoadingOverlay> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  OverlayState? _registeredOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_attachOverlay);
  }

  /// [FastLoadingController.detach] removes the visible entry; a pending
  /// request is kept for the next attach.
  /// [FastLoadingController.detach] 会移除当前条目，并保留 pending 供下次挂载。
  @override
  void dispose() {
    FastLoadingController.instance.detach(_registeredOverlay);
    super.dispose();
  }

  void _attachOverlay(Duration _) {
    if (!mounted) {
      return;
    }
    final OverlayState? overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      _registeredOverlay = overlayState;
      FastLoadingController.instance.attach(
        overlayState,
        navigatorKey: widget.navigatorKey,
      );
    }
  }

  @override
  void didUpdateWidget(FastLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.navigatorKey, widget.navigatorKey)) {
      FastLoadingController.instance.updateNavigatorKey(widget.navigatorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Overlay(
          key: _overlayKey,
          clipBehavior: Clip.none,
        ),
      ],
    );
  }
}
