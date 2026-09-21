import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../controller/fast_slidable_controller.dart';
import '../theme/fast_slidable_theme.dart';
import 'fast_slidable_dismiss.dart';
import 'fast_slidable_group.dart';
import 'fast_slidable_pane.dart';

/// A widget that can be dragged to reveal contextual actions.
/// 可拖动以露出上下文操作的组件。
///
/// When [startPane] or [endPane] sets [FastSlidableDismiss] (or a full swipe
/// that dismisses), [key] must be non-null so list items stay in sync.
/// 当 [startPane] / [endPane] 配置了 [FastSlidableDismiss]（或会删除的 `fullSwipe`）时，
/// [key] 必须非空，以免列表项错位。
class FastSlidable extends StatefulWidget {
  /// Creates a slidable.
  /// 创建可滑动组件。
  const FastSlidable({
    super.key,
    this.controller,
    this.groupTag,
    this.enabled = true,
    this.closeOnScroll = true,
    this.startPane,
    this.endPane,
    this.direction = Axis.horizontal,
    this.dragStartBehavior = DragStartBehavior.start,
    this.useTextDirection = true,
    required this.child,
  });

  /// Optional external controller. The caller must [dispose] it.
  /// 可选外部控制器。由调用方 [dispose]。
  ///
  /// The widget never disposes this instance, including when it is replaced
  /// in [State.didUpdateWidget]. If omitted, the State creates and disposes
  /// its own controller.
  /// 组件不会 dispose 该实例，包括在 [State.didUpdateWidget] 里被替换时。
  /// 未传入时由 State 自建自毁。
  final FastSlidableController? controller;

  /// Tag shared with other rows under [FastSlidableGroup].
  /// 在 [FastSlidableGroup] 下与其他行共享的标记。
  final Object? groupTag;

  /// Whether drag is enabled.
  /// 是否允许拖动。
  final bool enabled;

  /// Close when the nearest [Scrollable] starts scrolling.
  /// 最近的 [Scrollable] 开始滚动时关闭。
  final bool closeOnScroll;

  /// Pane revealed toward the start side (left in LTR, top when vertical).
  /// 起始侧操作区（LTR 为左；竖直时为上）。
  final FastSlidablePane? startPane;

  /// Pane revealed toward the end side (right in LTR, bottom when vertical).
  /// 末侧操作区（LTR 为右；竖直时为下）。
  final FastSlidablePane? endPane;

  /// Drag axis.
  /// 拖动轴。
  final Axis direction;

  /// Drag start behavior.
  /// 拖动起始行为。
  final DragStartBehavior dragStartBehavior;

  /// Whether [Directionality] flips start / end on the horizontal axis.
  /// 水平方向是否按 [Directionality] 对调 start / end。
  final bool useTextDirection;

  /// Content shown when the pane is closed.
  /// 关闭时展示的内容。
  final Widget child;

  /// The nearest enclosing [FastSlidableController], or `null`.
  /// 最近的 [FastSlidableController]；不存在时为 `null`。
  static FastSlidableController? of(BuildContext context) {
    return FastSlidableScope.maybeOf(context)?.controller;
  }

  @override
  State<FastSlidable> createState() => _FastSlidableState();
}

class _FastSlidableState extends State<FastSlidable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// Controller created by this State. Null when the caller passed one in.
  /// 本 State 自建的控制器。调用方传入时为 `null`。
  FastSlidableController? _ownedController;

  /// Owned instance waiting for descendants to drop listeners.
  /// 已退役的自建实例，等子组件卸完 listener 再 dispose。
  FastSlidableController? _retiredOwnedController;

  late Animation<Offset> _moveAnimation;

  /// Effective controller: external instance or the one this State owns.
  /// 生效控制器：外部实例，或本 State 自建的实例。
  FastSlidableController get _controller =>
      widget.controller ?? _ownedController!;

  @override
  bool get wantKeepAlive => !widget.closeOnScroll;

  bool get _needsDismissKey {
    return _paneNeedsKey(widget.startPane) || _paneNeedsKey(widget.endPane);
  }

  bool _paneNeedsKey(FastSlidablePane? pane) {
    if (pane == null) {
      return false;
    }
    return pane.dismiss != null || (pane.fullSwipe?.dismiss ?? false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = FastSlidableController(this);
    }
    _attachController(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyTheme();
    _updateDirectionality();
    _updateControllerExtents();
    _updateMoveAnimation();
  }

  @override
  void didUpdateWidget(covariant FastSlidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _reattachController(oldWidget.controller);
    }
    _applyTheme();
    _updateDirectionality();
    _updateControllerExtents();
    _updateMoveAnimation();
  }

  @override
  void dispose() {
    _detachController(_controller);
    _ownedController?.dispose();
    _disposeRetiredOwnedController();
    super.dispose();
  }

  void _attachController(FastSlidableController controller) {
    controller.paneType.addListener(_handlePaneTypeChanged);
  }

  void _detachController(FastSlidableController controller) {
    controller.paneType.removeListener(_handlePaneTypeChanged);
  }

  /// Rebinds listeners. Disposes only a controller this State created.
  /// 重绑 listener。只 dispose 本 State 自建的实例。
  void _reattachController(FastSlidableController? previousExternal) {
    final FastSlidableController previous =
        previousExternal ?? _ownedController!;
    _detachController(previous);
    if (previousExternal == null) {
      // Descendants still need to removeListener in their didUpdateWidget.
      // 子组件还要在自己的 didUpdateWidget 里卸 listener。
      _retireOwnedController(previous);
      _ownedController = null;
    }
    if (widget.controller == null) {
      _ownedController = FastSlidableController(this);
    }
    _attachController(_controller);
  }

  void _retireOwnedController(FastSlidableController owned) {
    _disposeRetiredOwnedController();
    _retiredOwnedController = owned;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (identical(_retiredOwnedController, owned)) {
        _disposeRetiredOwnedController();
      }
    });
  }

  void _disposeRetiredOwnedController() {
    _retiredOwnedController?.dispose();
    _retiredOwnedController = null;
  }

  void _assertDismissKey() {
    assert(() {
      if (_needsDismissKey && widget.key == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('FastSlidableDismiss requires a Key on FastSlidable.'),
          ErrorDescription(
            'Dismiss and full-swipe-dismiss are commonly used in lists. '
            'Without a key, Flutter syncs state by index and the next row '
            'inherits the dismissed item\'s state.',
          ),
          ErrorHint('Set key: ValueKey(item.id) on FastSlidable.'),
        ]);
      }
      return true;
    }());
  }

  void _applyTheme() {
    final FastSlidableTheme theme = FastSlidableTheme.resolve(context);
    _controller
      ..movementDuration = theme.movementDuration
      ..movementCurve = theme.movementCurve;
  }

  void _updateControllerExtents() {
    _controller
      ..enableStartPane = widget.startPane != null
      ..startExtentRatio =
          widget.startPane?.extentRatio ?? kFastSlidableExtentRatio
      ..enableEndPane = widget.endPane != null
      ..endExtentRatio = widget.endPane?.extentRatio ?? kFastSlidableExtentRatio;
  }

  void _updateDirectionality() {
    final TextDirection textDirection = Directionality.of(context);
    _controller.isLeftToRight = widget.direction == Axis.vertical ||
        !widget.useTextDirection ||
        textDirection == TextDirection.ltr;
  }

  void _handlePaneTypeChanged() {
    setState(() {
      _updateMoveAnimation();
    });
  }

  void _updateMoveAnimation() {
    final double end = _controller.direction.value.toDouble();
    _moveAnimation = _controller.animation.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: widget.direction == Axis.horizontal
            ? Offset(end, 0)
            : Offset(0, end),
      ),
    );
  }

  FastSlidablePane? get _actionPane {
    switch (_controller.paneType.value) {
      case FastSlidablePaneType.start:
        return widget.startPane;
      case FastSlidablePaneType.end:
        return widget.endPane;
      case FastSlidablePaneType.none:
        return null;
    }
  }

  Alignment get _paneAlignment {
    final double sign = _controller.direction.value.toDouble();
    if (widget.direction == Axis.horizontal) {
      return Alignment(-sign, 0);
    }
    return Alignment(0, -sign);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _assertDismissKey();
    Widget content = SlideTransition(
      position: _moveAnimation,
      child: FastSlidableGroupInteractor(
        groupTag: widget.groupTag,
        controller: _controller,
        child: widget.child,
      ),
    );

    content = Stack(
      children: <Widget>[
        if (_actionPane != null)
          Positioned.fill(
            child: ClipRect(
              clipper: _FastSlidableClipper(
                axis: widget.direction,
                controller: _controller,
              ),
              child: _actionPane,
            ),
          ),
        content,
      ],
    );

    return FastSlidableRefreshLock(
      controller: _controller,
      child: _FastSlidableGesture(
        enabled: widget.enabled,
        controller: _controller,
        direction: widget.direction,
        dragStartBehavior: widget.dragStartBehavior,
        child: FastSlidableScrollCloser(
          controller: _controller,
          closeOnScroll: widget.closeOnScroll,
          child: FastSlidableDismissal(
            axis: flipAxis(widget.direction),
            controller: _controller,
            child: FastSlidableScope(
              controller: _controller,
              direction: widget.direction,
              alignment: _paneAlignment,
              isStartPane:
                  _controller.paneType.value == FastSlidablePaneType.start,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _FastSlidableGesture extends StatefulWidget {
  const _FastSlidableGesture({
    required this.enabled,
    required this.controller,
    required this.direction,
    required this.dragStartBehavior,
    required this.child,
  });

  final bool enabled;
  final FastSlidableController controller;
  final Axis direction;
  final DragStartBehavior dragStartBehavior;
  final Widget child;

  @override
  State<_FastSlidableGesture> createState() => _FastSlidableGestureState();
}

class _FastSlidableGestureState extends State<_FastSlidableGesture> {
  double _dragExtent = 0;
  Offset _startPosition = Offset.zero;
  Offset _lastPosition = Offset.zero;
  bool _dragging = false;

  bool get _isX => widget.direction == Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _isX && widget.enabled ? _onStart : null,
      onHorizontalDragUpdate: _isX && widget.enabled ? _onUpdate : null,
      onHorizontalDragEnd: _isX && widget.enabled ? _onEnd : null,
      onVerticalDragStart: !_isX && widget.enabled ? _onStart : null,
      onVerticalDragUpdate: !_isX && widget.enabled ? _onUpdate : null,
      onVerticalDragEnd: !_isX && widget.enabled ? _onEnd : null,
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: widget.dragStartBehavior,
      child: widget.child,
    );
  }

  double get _extent {
    final Size size = context.size!;
    return _isX ? size.width : size.height;
  }

  bool get _refreshLocked => FastSlidableRefreshLock.isActive(context);

  void _onStart(DragStartDetails details) {
    if (_refreshLocked) {
      _dragging = false;
      widget.controller.close();
      return;
    }
    _dragging = true;
    _startPosition = details.localPosition;
    _lastPosition = _startPosition;
    _dragExtent = widget.controller.ratio * _extent;
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!_dragging || _refreshLocked) {
      _dragging = false;
      widget.controller.close();
      return;
    }
    _dragExtent += details.primaryDelta ?? 0;
    _lastPosition = details.localPosition;
    widget.controller.ratio = _dragExtent / _extent;
  }

  void _onEnd(DragEndDetails details) {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    final Offset delta = _lastPosition - _startPosition;
    final double primary = _isX ? delta.dx : delta.dy;
    final FastSlidableGestureKind kind = primary >= 0
        ? FastSlidableGestureKind.opening
        : FastSlidableGestureKind.closing;
    widget.controller.dispatchEndGesture(details.primaryVelocity, kind);
  }
}

class _FastSlidableClipper extends CustomClipper<Rect> {
  _FastSlidableClipper({
    required this.axis,
    required this.controller,
  }) : super(reclip: controller.animation);

  final Axis axis;
  final FastSlidableController controller;

  @override
  Rect getClip(Size size) {
    switch (axis) {
      case Axis.horizontal:
        final double offset = controller.ratio * size.width;
        if (offset < 0) {
          return Rect.fromLTRB(size.width + offset, 0, size.width, size.height);
        }
        return Rect.fromLTRB(0, 0, offset, size.height);
      case Axis.vertical:
        final double offset = controller.ratio * size.height;
        if (offset < 0) {
          return Rect.fromLTRB(
            0,
            size.height + offset,
            size.width,
            size.height,
          );
        }
        return Rect.fromLTRB(0, 0, size.width, offset);
    }
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_FastSlidableClipper oldClipper) {
    return oldClipper.axis != axis;
  }
}
