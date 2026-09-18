import 'package:flutter/widgets.dart';

import '../controller/fast_slidable_controller.dart';
import '../motion/fast_slidable_motion.dart';
import '../theme/fast_slidable_theme.dart';
import 'fast_slidable_action.dart';
import 'fast_slidable_dismiss.dart';

/// Ambient data for the active [FastSlidablePane].
/// 当前 [FastSlidablePane] 的环境数据。
@immutable
class FastSlidablePaneData {
  /// Creates pane data.
  /// 创建操作区数据。
  const FastSlidablePaneData({
    required this.extentRatio,
    required this.alignment,
    required this.direction,
    required this.fromStart,
    required this.primaryIndex,
    required this.children,
  });

  /// Pane extent as a fraction of the slidable.
  /// 操作区占 slided 尺寸的比例。
  final double extentRatio;

  /// Alignment used to pin the pane.
  /// 钉住操作区的对齐。
  final Alignment alignment;

  /// Slide axis.
  /// 滑动轴。
  final Axis direction;

  /// Whether this is the start pane.
  /// 是否为起始侧。
  final bool fromStart;

  /// Index of the primary action (full swipe).
  /// 主操作下标（满滑）。
  final int primaryIndex;

  /// Action widgets.
  /// 操作组件。
  final List<Widget> children;
}

/// Inherited scope for [FastSlidablePaneData].
/// [FastSlidablePaneData] 的 Inherited 作用域。
class FastSlidablePaneScope extends InheritedWidget {
  /// Creates a pane scope.
  /// 创建操作区作用域。
  const FastSlidablePaneScope({
    super.key,
    required this.data,
    required super.child,
  });

  /// Ambient pane data.
  /// 环境操作区数据。
  final FastSlidablePaneData data;

  @override
  bool updateShouldNotify(FastSlidablePaneScope oldWidget) {
    return data != oldWidget.data;
  }
}

/// One side of actions revealed by [FastSlidable].
/// [FastSlidable] 一侧露出的操作区。
class FastSlidablePane extends StatefulWidget {
  /// Creates an action pane.
  /// 创建操作区。
  ///
  /// When [fullSwipe.dismiss] is `true`, [dismiss] is required.
  /// [fullSwipe.dismiss] 为 `true` 时必须提供 [dismiss]。
  FastSlidablePane({
    super.key,
    this.extentRatio = kFastSlidableExtentRatio,
    this.motion = FastSlidableMotion.scroll,
    this.motionBuilder,
    this.dismiss,
    this.fullSwipe,
    this.openThreshold,
    this.closeThreshold,
    required this.children,
  })  : assert(extentRatio > 0 && extentRatio <= 1),
        assert(
          openThreshold == null || (openThreshold > 0 && openThreshold < 1),
        ),
        assert(
          closeThreshold == null || (closeThreshold > 0 && closeThreshold < 1),
        ),
        assert(
          fullSwipe == null || fullSwipe.dismiss == false || dismiss != null,
          'fullSwipe.dismiss requires FastSlidableDismiss.',
        );

  /// Fraction of the slidable occupied when the pane is open.
  /// 打开后操作区占 slided 的比例。
  final double extentRatio;

  /// Built-in reveal animation.
  /// 内置露出动画。
  final FastSlidableMotion motion;

  /// Optional custom motion. Overrides [motion] when set.
  /// 可选自定义动画。设置后覆盖 [motion]。
  final FastSlidableMotionBuilder? motionBuilder;

  /// Swipe-away deletion. Requires a [Key] on the enclosing [FastSlidable].
  /// 滑出删除。外层 [FastSlidable] 必须带 [Key]。
  final FastSlidableDismiss? dismiss;

  /// iOS-style full swipe that expands the primary action.
  /// iOS 式满滑，主操作铺满。
  final FastSlidableFullSwipe? fullSwipe;

  /// Absolute ratio at which a still / opening gesture opens the pane.
  /// Defaults to half of [extentRatio].
  /// 静止 / 打开手势下打开操作区的绝对比例。默认是 [extentRatio] 的一半。
  final double? openThreshold;

  /// Absolute ratio below which a closing gesture closes the pane.
  /// Defaults to half of [extentRatio].
  /// 关闭手势下收回操作区的绝对比例。默认是 [extentRatio] 的一半。
  final double? closeThreshold;

  /// Actions. Prefer [FastSlidableAction] / [FastSlidableCustomAction].
  /// 操作列表。推荐 [FastSlidableAction] / [FastSlidableCustomAction]。
  final List<Widget> children;

  /// Reads ambient pane data, or `null`.
  /// 读取环境操作区数据；不存在时为 `null`。
  static FastSlidablePaneData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FastSlidablePaneScope>()
        ?.data;
  }

  @override
  State<FastSlidablePane> createState() => _FastSlidablePaneState();
}

class _FastSlidablePaneState extends State<FastSlidablePane>
    implements FastSlidableRatioConfigurator {
  FastSlidableController? _controller;
  late double _openThreshold;
  late double _closeThreshold;
  bool _showRevealMotion = true;

  @override
  double get extentRatio => widget.extentRatio;

  int get _primaryIndex {
    final int? explicit = widget.fullSwipe?.primaryIndex;
    if (explicit != null) {
      return explicit.clamp(0, widget.children.length - 1);
    }
    final FastSlidableScope? scope =
        FastSlidableScope.maybeOf(context, listen: false);
    final bool fromStart = scope?.isStartPane ?? true;
    return fromStart ? 0 : widget.children.length - 1;
  }

  @override
  void initState() {
    super.initState();
    _controller = FastSlidableScope.maybeOf(context, listen: false)?.controller;
    _controller!.endGesture.addListener(handleEndGestureChanged);
    if (widget.dismiss != null || widget.fullSwipe != null) {
      _controller!.animation.addListener(_handleRatioChanged);
    }
    _updateThresholds();
    _controller!.configurator = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FastSlidableController? next =
        FastSlidableScope.maybeOf(context)?.controller;
    if (next != _controller && next != null) {
      _controller?.endGesture.removeListener(handleEndGestureChanged);
      _controller?.animation.removeListener(_handleRatioChanged);
      if (_controller?.configurator == this) {
        _controller?.configurator = null;
      }
      _controller = next;
      _controller!.endGesture.addListener(handleEndGestureChanged);
      if (widget.dismiss != null || widget.fullSwipe != null) {
        _controller!.animation.addListener(_handleRatioChanged);
      }
      _controller!.configurator = this;
    }
  }

  @override
  void didUpdateWidget(covariant FastSlidablePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismiss != null || oldWidget.fullSwipe != null) {
      _controller!.animation.removeListener(_handleRatioChanged);
    }
    if (widget.dismiss == null && widget.fullSwipe == null) {
      _showRevealMotion = true;
    } else {
      _controller!.animation.addListener(_handleRatioChanged);
    }
    _updateThresholds();
  }

  @override
  void dispose() {
    _controller?.endGesture.removeListener(handleEndGestureChanged);
    _controller?.animation.removeListener(_handleRatioChanged);
    if (_controller?.configurator == this) {
      _controller?.configurator = null;
    }
    super.dispose();
  }

  void _updateThresholds() {
    _openThreshold = widget.openThreshold ?? widget.extentRatio / 2;
    _closeThreshold = widget.closeThreshold ?? widget.extentRatio / 2;
  }

  @override
  double normalizeRatio(double ratio) {
    final bool canOvershoot =
        widget.dismiss != null || widget.fullSwipe != null;
    if (canOvershoot) {
      return ratio;
    }
    final double absolute = ratio.abs().clamp(0.0, widget.extentRatio);
    return ratio < 0 ? -absolute : absolute;
  }

  @override
  void handleEndGestureChanged() {
    final FastSlidableController controller = _controller!;
    final FastSlidableEndGesture? gesture = controller.endGesture.value;
    final double position = controller.animation.value;
    final FastSlidableFullSwipe? fullSwipe = widget.fullSwipe;
    final FastSlidableDismiss? dismiss = widget.dismiss;

    if (fullSwipe != null && position >= fullSwipe.threshold) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _triggerFullSwipe();
        }
      });
      return;
    }

    if (dismiss != null && position >= dismiss.threshold) {
      if (controller.isDismissReady) {
        controller.dismissIntent.value = gesture;
      } else {
        controller.openCurrent();
      }
      return;
    }

    if ((gesture is FastSlidableOpeningGesture &&
            _openThreshold <= extentRatio) ||
        (gesture is FastSlidableStillGesture &&
            ((gesture.opening && position >= _openThreshold) ||
                (!gesture.opening && position > _closeThreshold)))) {
      controller.openCurrent();
      return;
    }

    controller.close();
  }

  void _handleRatioChanged() {
    final bool pastExtent = _controller!.ratio.abs() > widget.extentRatio &&
        (_controller!.isDismissReady || widget.fullSwipe != null);
    final bool show = !pastExtent;
    if (show != _showRevealMotion) {
      setState(() {
        _showRevealMotion = show;
      });
    }
  }

  Future<void> _triggerFullSwipe() async {
    final FastSlidableFullSwipe? fullSwipe = widget.fullSwipe;
    if (fullSwipe == null) {
      return;
    }
    fullSwipe.onTriggered?.call();
    _invokePrimaryAction();
    if (!mounted) {
      return;
    }
    if (fullSwipe.dismiss) {
      await _runDismiss();
    } else {
      await _controller!.openCurrent();
    }
  }

  void _invokePrimaryAction() {
    if (widget.children.isEmpty) {
      return;
    }
    final Widget child = widget.children[_primaryIndex];
    if (child is FastSlidableAction) {
      child.onPressed?.call(context);
    } else if (child is FastSlidableCustomAction) {
      child.onPressed?.call(context);
    }
  }

  Future<void> _runDismiss() async {
    final FastSlidableDismiss? dismiss = widget.dismiss;
    final FastSlidableController controller = _controller!;
    if (dismiss == null) {
      await controller.openCurrent();
      return;
    }
    bool canDismiss = true;
    if (dismiss.confirmDismiss != null) {
      canDismiss = await dismiss.confirmDismiss!();
    }
    if (!mounted) {
      return;
    }
    if (!canDismiss) {
      if (dismiss.closeOnCancel) {
        await controller.close();
      } else {
        await controller.openCurrent();
      }
      return;
    }
    await controller.dismiss(
      FastSlidableResizeRequest(dismiss.resizeDuration, dismiss.onDismissed),
      duration: dismiss.dismissalDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FastSlidableScope scope = FastSlidableScope.maybeOf(context)!;
    final FastSlidableTheme theme = FastSlidableTheme.resolve(context);
    _controller!
      ..movementDuration = theme.movementDuration
      ..movementCurve = theme.movementCurve;

    final FastSlidablePaneData data = FastSlidablePaneData(
      extentRatio: widget.extentRatio,
      alignment: scope.alignment,
      direction: scope.direction,
      fromStart: scope.isStartPane,
      primaryIndex: _primaryIndex,
      children: widget.children,
    );

    final Widget motionChild;
    if (_showRevealMotion) {
      motionChild = FractionallySizedBox(
        alignment: scope.alignment,
        widthFactor: scope.direction == Axis.horizontal ? extentRatio : null,
        heightFactor: scope.direction == Axis.horizontal ? null : extentRatio,
        child: widget.motionBuilder != null
            ? widget.motionBuilder!(context, data, scope.controller)
            : FastSlidableMotionHost(motion: widget.motion),
      );
    } else {
      motionChild = FastSlidableExpandMotion(
        primaryIndex: _primaryIndex,
      );
    }

    return FastSlidablePaneScope(
      data: data,
      child: _FastSlidableDismissBinder(
        dismiss: widget.dismiss,
        child: motionChild,
      ),
    );
  }
}

class _FastSlidableDismissBinder extends StatefulWidget {
  const _FastSlidableDismissBinder({
    required this.dismiss,
    required this.child,
  });

  final FastSlidableDismiss? dismiss;
  final Widget child;

  @override
  State<_FastSlidableDismissBinder> createState() =>
      _FastSlidableDismissBinderState();
}

class _FastSlidableDismissBinderState extends State<_FastSlidableDismissBinder> {
  FastSlidableController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FastSlidableScope.maybeOf(context, listen: false)?.controller;
    _controller?.dismissIntent.addListener(_handleDismissIntent);
  }

  @override
  void dispose() {
    _controller?.dismissIntent.removeListener(_handleDismissIntent);
    super.dispose();
  }

  Future<void> _handleDismissIntent() async {
    final FastSlidableDismiss? dismiss = widget.dismiss;
    final FastSlidableController? controller = _controller;
    if (dismiss == null || controller == null) {
      return;
    }
    if (controller.animation.value < dismiss.threshold) {
      await controller.openCurrent();
      return;
    }
    bool canDismiss = true;
    if (dismiss.confirmDismiss != null) {
      canDismiss = await dismiss.confirmDismiss!();
    }
    if (!mounted) {
      return;
    }
    if (!canDismiss) {
      if (dismiss.closeOnCancel) {
        await controller.close();
      } else {
        await controller.openCurrent();
      }
      return;
    }
    await controller.dismiss(
      FastSlidableResizeRequest(dismiss.resizeDuration, dismiss.onDismissed),
      duration: dismiss.dismissalDuration,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
