import 'dart:async';

import 'package:flutter/material.dart';

import '../fast_toast_position.dart';
import '../fast_toast_queue.dart';
import '../fast_toast_theme.dart';
import 'fast_toast_keyboard_shift.dart';

/// Overlay entry content: themed text panel or custom child, with motion.
/// Overlay 条目内容：主题化文本面板或自定义子组件，带入出场动画。
class FastToastView extends StatefulWidget {
  /// Creates overlay content for a single [request].
  /// 为单条 [request] 创建 Overlay 内容。
  const FastToastView({
    super.key,
    required this.request,
    required this.onDismissed,
    required this.onRegisterDismiss,
  });

  /// The toast to display.
  /// 要展示的 Toast 请求。
  final FastToastRequest request;

  /// Called after the exit animation finishes.
  /// 退场动画结束后回调。
  final VoidCallback onDismissed;

  /// Receives a callback that plays the exit animation.
  /// 接收用于播放退场动画的回调。
  final void Function(VoidCallback dismiss) onRegisterDismiss;

  @override
  State<FastToastView> createState() => _FastToastViewState();
}

class _FastToastViewState extends State<FastToastView>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _horizontalMargin = 24;

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  Animation<Offset>? _slide;

  Timer? _autoDismissTimer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    final FastToastPosition position = widget.request.config.position;

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _controller.addStatusListener(_onStatus);

    final Animation<double> curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _opacity = curved;

    if (position != FastToastPosition.center) {
      _slide = Tween<Offset>(
        begin: _slideBeginFor(position),
        end: Offset.zero,
      ).animate(curved);
    }

    widget.onRegisterDismiss(_dismiss);
    _controller.forward();
    _autoDismissTimer = Timer(widget.request.config.duration, _dismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _isDismissed && mounted) {
      widget.onDismissed();
    }
  }

  void _dismiss() {
    if (_isDismissed) {
      return;
    }
    _isDismissed = true;
    _autoDismissTimer?.cancel();
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.request.config;
    final Widget body = widget.request.isText
        ? _FastToastTextPanel(message: widget.request.message!)
        : widget.request.child!;

    Widget content = body;
    if (config.dismissible) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: content,
      );
    }

    Widget animated = FadeTransition(
      opacity: _opacity,
      child: _slide == null
          ? content
          : SlideTransition(position: _slide!, child: content),
    );

    if (widget.request.isText) {
      animated = Semantics(
        liveRegion: true,
        label: widget.request.message,
        child: animated,
      );
    }

    return Align(
      alignment: config.position.alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
        child: FastToastKeyboardShift(
          position: config.position,
          child: animated,
        ),
      ),
    );
  }
}

class _FastToastTextPanel extends StatelessWidget {
  const _FastToastTextPanel({required this.message});

  static const double _maxWidth = 400;

  final String message;

  @override
  Widget build(BuildContext context) {
    final FastToastTheme theme = FastToastTheme.resolve(context);
    final BorderRadius radius = BorderRadius.circular(theme.borderRadius);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: radius,
          boxShadow: theme.boxShadow,
        ),
        child: Padding(
          padding: theme.padding,
          child: Text(
            message,
            style: theme.textStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Offset _slideBeginFor(FastToastPosition position) {
  return switch (position) {
    FastToastPosition.top => const Offset(0, -0.2),
    FastToastPosition.bottom => const Offset(0, 0.2),
    FastToastPosition.center => Offset.zero,
  };
}
