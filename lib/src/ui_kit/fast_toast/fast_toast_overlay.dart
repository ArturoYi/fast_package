import 'package:flutter/material.dart';

import 'fast_toast_controller.dart';

/// Host widget mounted from [MaterialApp.builder] to provide a toast overlay.
/// 挂在 [MaterialApp.builder] 上、为 Toast 提供 Overlay 的宿主。
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return FastToastOverlay(
///       child: child ?? const SizedBox.shrink(),
///     );
///   },
/// )
/// ```
class FastToastOverlay extends StatefulWidget {
  /// Wraps [child] and registers an [Overlay] with the toast controller.
  /// 包裹 [child]，并向 Toast 调度器注册 [Overlay]。
  const FastToastOverlay({
    super.key,
    required this.child,
  });

  /// The app subtree under the toast overlay.
  /// Overlay 下方的应用子树。
  final Widget child;

  @override
  State<FastToastOverlay> createState() => _FastToastOverlayState();
}

class _FastToastOverlayState extends State<FastToastOverlay> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  OverlayState? _registeredOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_attachOverlay);
  }

  /// [FastToastController.detach] removes the visible entry but keeps pending.
  /// [FastToastController.detach] 会移除当前条目，但保留 pending 队列。
  @override
  void dispose() {
    FastToastController.instance.detach(_registeredOverlay);
    super.dispose();
  }

  void _attachOverlay(Duration _) {
    if (!mounted) {
      return;
    }
    final OverlayState? overlayState = _overlayKey.currentState;
    if (overlayState != null) {
      _registeredOverlay = overlayState;
      FastToastController.instance.attach(overlayState);
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
