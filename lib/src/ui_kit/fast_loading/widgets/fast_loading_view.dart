import 'package:flutter/material.dart';

import '../fast_loading_request.dart';
import '../fast_loading_theme.dart';

/// Overlay entry content: themed spinner panel or custom child, with fade.
/// Overlay 条目内容：主题化转圈面板或自定义子组件，带淡入淡出。
class FastLoadingView extends StatefulWidget {
  /// Creates overlay content for a single [request].
  /// 为单次 [request] 创建 Overlay 内容。
  const FastLoadingView({
    super.key,
    required this.request,
    required this.onDismissed,
    required this.onRegisterDismiss,
  });

  /// The loading to display.
  /// 要展示的 Loading 请求。
  final FastLoadingRequest request;

  /// Called after the exit animation finishes.
  /// 退场动画结束后回调。
  final VoidCallback onDismissed;

  /// Receives a callback that plays the exit animation.
  /// 接收用于播放退场动画的回调。
  final void Function(VoidCallback dismiss) onRegisterDismiss;

  @override
  State<FastLoadingView> createState() => _FastLoadingViewState();
}

class _FastLoadingViewState extends State<FastLoadingView>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 200);

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _controller.addStatusListener(_onStatus);

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    widget.onRegisterDismiss(_dismiss);
    _controller.forward();
  }

  @override
  void dispose() {
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
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FastLoadingTheme theme = FastLoadingTheme.resolve(context);
    final bool barrierDismissible = widget.request.config.barrierDismissible;
    final Widget body = widget.request.isCustom
        ? widget.request.builder!(context)
        : _FastLoadingPanel(request: widget.request, theme: theme);

    final Widget content = Semantics(
      liveRegion: true,
      label: widget.request.hasMessage
          ? widget.request.message
          : (widget.request.isCustom ? null : 'Loading'),
      child: body,
    );

    return FadeTransition(
      opacity: _opacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModalBarrier(
            color: theme.barrierColor,
            dismissible: barrierDismissible,
            onDismiss: barrierDismissible ? _dismiss : null,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom / 2,
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _FastLoadingPanel extends StatelessWidget {
  const _FastLoadingPanel({
    required this.request,
    required this.theme,
  });

  static const double _maxWidth = 240;
  static const double _indicatorSize = 28;

  final FastLoadingRequest request;
  final FastLoadingTheme theme;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _indicatorSize,
                height: _indicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.indicatorColor,
                ),
              ),
              if (request.hasMessage) ...[
                const SizedBox(height: 12),
                Text(
                  request.message!.trim(),
                  style: theme.textStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
