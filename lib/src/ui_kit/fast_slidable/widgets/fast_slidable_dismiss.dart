import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../controller/fast_slidable_controller.dart';

/// Configures swipe-away deletion for a [FastSlidablePane].
/// 配置 [FastSlidablePane] 的滑出删除。
///
/// The enclosing [FastSlidable] **must** have a [Key] when this is set.
/// 设置此项时，外层 [FastSlidable] **必须**带 [Key]。
class FastSlidableDismiss {
  /// Creates a dismiss configuration.
  /// 创建删除配置。
  const FastSlidableDismiss({
    required this.onDismissed,
    this.threshold = 0.75,
    this.dismissalDuration = const Duration(milliseconds: 300),
    this.resizeDuration = const Duration(milliseconds: 300),
    this.confirmDismiss,
    this.closeOnCancel = false,
  }) : assert(threshold > 0 && threshold < 1);

  /// Called after the row has finished shrinking. Remove the item here.
  /// 行高收缩结束后调用。应在此移除条目。
  final VoidCallback onDismissed;

  /// Absolute animation value (`0..1`) at which release triggers dismiss.
  /// 松手时触发删除的绝对动画值（`0..1`）。
  final double threshold;

  /// Duration of the swipe-to-full animation.
  /// 滑满动画时长。
  final Duration dismissalDuration;

  /// Duration of the shrink animation.
  /// 收缩动画时长。
  final Duration resizeDuration;

  /// Confirm or veto a pending dismiss. `false` / `null` cancels.
  /// 确认或否决即将发生的删除。返回 `false` / `null` 则取消。
  final Future<bool> Function()? confirmDismiss;

  /// Whether to close the pane when dismiss is cancelled.
  /// 取消删除时是否关闭操作区。
  final bool closeOnCancel;
}

/// iOS Mail-style full swipe: past [threshold] the primary action expands.
/// iOS 邮件式满滑：超过 [threshold] 后主操作铺满。
class FastSlidableFullSwipe {
  /// Creates a full-swipe configuration.
  /// 创建满滑配置。
  ///
  /// When [dismiss] is `true`, the pane must also set [FastSlidableDismiss].
  /// [dismiss] 为 `true` 时，操作区还必须设置 [FastSlidableDismiss]。
  const FastSlidableFullSwipe({
    this.threshold = 0.55,
    this.dismiss = true,
    this.primaryIndex,
    this.onTriggered,
  }) : assert(threshold > 0 && threshold < 1);

  /// Absolute animation value that starts the full-swipe path.
  /// 进入满滑路径的绝对动画值。
  final double threshold;

  /// Whether release after a full swipe also shrinks and removes the row.
  /// 满滑松手后是否同时收缩并移除该行。
  final bool dismiss;

  /// Primary action index. Default: `0` on start pane, last on end pane.
  /// 主操作下标。默认：起始侧为 `0`，末侧为最后一个。
  final int? primaryIndex;

  /// Extra hook when a full swipe fires. The primary action is still invoked.
  /// 满滑触发时的额外钩子。仍会调用主操作的 `onPressed`。
  final VoidCallback? onTriggered;
}

/// Shrinks the slidable after [FastSlidableController.dismiss].
/// 在 [FastSlidableController.dismiss] 之后收缩组件。
class FastSlidableDismissal extends StatefulWidget {
  /// Creates a dismissal host.
  /// 创建删除宿主。
  const FastSlidableDismissal({
    super.key,
    required this.axis,
    required this.controller,
    required this.child,
  });

  /// Axis of the shrink (the opposite of the slide axis).
  /// 收缩轴（与滑动轴垂直）。
  final Axis axis;

  /// Slidable controller.
  /// 滑动控制器。
  final FastSlidableController controller;

  /// Wrapped content.
  /// 被包裹的内容。
  final Widget child;

  @override
  State<FastSlidableDismissal> createState() => _FastSlidableDismissalState();
}

class _FastSlidableDismissalState extends State<FastSlidableDismissal>
    with SingleTickerProviderStateMixin {
  bool _resizing = false;
  bool _notifiedDismissed = false;
  late final AnimationController _resizeController;
  late final Animation<double> _resizeAnimation;

  @override
  void initState() {
    super.initState();
    _resizeController = AnimationController(vsync: this);
    _resizeAnimation = _resizeController.drive(Tween<double>(begin: 1, end: 0));
    widget.controller.resizeRequest.addListener(_handleResizeRequest);
  }

  @override
  void didUpdateWidget(covariant FastSlidableDismissal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.resizeRequest.removeListener(_handleResizeRequest);
      widget.controller.resizeRequest.addListener(_handleResizeRequest);
    }
  }

  @override
  void dispose() {
    widget.controller.resizeRequest.removeListener(_handleResizeRequest);
    _resizeController.dispose();
    super.dispose();
  }

  void _handleResizeRequest() {
    final FastSlidableResizeRequest? request =
        widget.controller.resizeRequest.value;
    if (request == null || _resizing) {
      return;
    }
    if (widget.controller.animation.status != AnimationStatus.completed) {
      return;
    }
    _resizing = true;
    _resizeController.duration = request.duration;
    _resizeController.forward(from: 0).whenComplete(() {
      if (!mounted ||
          _notifiedDismissed ||
          _resizeController.status != AnimationStatus.completed) {
        return;
      }
      _notifiedDismissed = true;
      request.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _UnclippedSizeTransition(
      sizeFactor: _resizeAnimation,
      axis: widget.axis,
      child: widget.child,
    );
  }
}

/// Size transition that does not clip when the factor is `1`.
/// 比例为 `1` 时不裁剪的尺寸过渡。
class _UnclippedSizeTransition extends AnimatedWidget {
  const _UnclippedSizeTransition({
    required this.axis,
    required Animation<double> sizeFactor,
    required this.child,
  }) : super(listenable: sizeFactor);

  final Axis axis;
  final Widget child;

  Animation<double> get sizeFactor => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final double value = math.max(sizeFactor.value, 0);
    final AlignmentDirectional alignment = axis == Axis.vertical
        ? const AlignmentDirectional(-1, 0)
        : const AlignmentDirectional(0, -1);
    return ClipRect(
      clipBehavior: value == 1 ? Clip.none : Clip.hardEdge,
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical ? value : null,
        widthFactor: axis == Axis.horizontal ? value : null,
        child: child,
      ),
    );
  }
}
