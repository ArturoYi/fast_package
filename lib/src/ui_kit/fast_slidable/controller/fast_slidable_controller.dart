import 'package:flutter/widgets.dart';

/// Default pane extent as a fraction of the [FastSlidable] size.
/// [FastSlidable] 尺寸上，操作区默认占比。
const double kFastSlidableExtentRatio = 0.4;

const Duration _kDefaultMovementDuration = Duration(milliseconds: 200);
const Curve _kDefaultMovementCurve = Curves.ease;

/// Which action pane is currently visible.
/// 当前露出的是哪一侧操作区。
enum FastSlidablePaneType {
  /// The end pane (right in LTR, bottom when vertical).
  /// 末侧操作区（LTR 为右；竖直时为下）。
  end,

  /// No pane is shown.
  /// 未露出操作区。
  none,

  /// The start pane (left in LTR, top when vertical).
  /// 起始操作区（LTR 为左；竖直时为上）。
  start,
}

/// Direction of a completed drag relative to opening the pane.
/// 松手时相对「打开操作区」的方向。
enum FastSlidableGestureKind {
  /// The drag was opening the pane.
  /// 正在打开。
  opening,

  /// The drag was closing the pane.
  /// 正在关闭。
  closing,
}

/// A request to shrink the row after a dismiss animation.
/// 删除动画结束后收缩行高的请求。
@immutable
class FastSlidableResizeRequest {
  /// Creates a resize request.
  /// 创建收缩请求。
  const FastSlidableResizeRequest(this.duration, this.onDismissed);

  /// How long the shrink animation lasts.
  /// 收缩动画时长。
  final Duration duration;

  /// Called after the shrink finishes. Remove the row here.
  /// 收缩结束后调用。应在此移除该行。
  final VoidCallback onDismissed;
}

/// End-of-drag signal used by the active pane.
/// 松手信号，由当前操作区消费。
@immutable
class FastSlidableEndGesture {
  /// Creates an end gesture.
  /// 创建松手信号。
  const FastSlidableEndGesture(this.velocity);

  /// Drag velocity along the slidable axis. `0` when still.
  /// 沿滑动轴的速度；静止时为 `0`。
  final double velocity;
}

/// Fast flick that should open the pane.
/// 快速轻扫，应打开操作区。
class FastSlidableOpeningGesture extends FastSlidableEndGesture {
  /// Creates an opening gesture.
  /// 创建打开手势。
  const FastSlidableOpeningGesture(super.velocity);
}

/// Fast flick that should close the pane.
/// 快速轻扫，应关闭操作区。
class FastSlidableClosingGesture extends FastSlidableEndGesture {
  /// Creates a closing gesture.
  /// 创建关闭手势。
  const FastSlidableClosingGesture(super.velocity);
}

/// Drag ended with no meaningful velocity.
/// 松手时几乎没有速度。
class FastSlidableStillGesture extends FastSlidableEndGesture {
  /// Creates a still gesture.
  /// 创建静止松手信号。
  const FastSlidableStillGesture(this.kind) : super(0);

  /// Whether the last movement was opening or closing.
  /// 最后一段位移是打开还是关闭。
  final FastSlidableGestureKind kind;

  /// Whether the user was opening.
  /// 用户是否正在打开。
  bool get opening => kind == FastSlidableGestureKind.opening;
}

/// Normalizes drag ratio and reacts to end gestures.
/// 限制拖动比例，并响应松手。
abstract class FastSlidableRatioConfigurator {
  /// Clamps [ratio] to the pane's allowed range.
  /// 将 [ratio] 限制在操作区允许范围内。
  double normalizeRatio(double ratio);

  /// Extent of this pane as a fraction of the slidable.
  /// 本侧操作区占 slided 尺寸的比例。
  double get extentRatio;

  /// Called when a drag ends.
  /// 松手时调用。
  void handleEndGestureChanged();
}

/// Inherited scope for the nearest [FastSlidable].
/// 最近的 [FastSlidable] 作用域。
class FastSlidableScope extends InheritedWidget {
  /// Creates a scope.
  /// 创建作用域。
  const FastSlidableScope({
    super.key,
    required this.controller,
    required this.direction,
    required this.alignment,
    required this.isStartPane,
    required super.child,
  });

  /// Controller of the enclosing slidable.
  /// 外层滑动组件的控制器。
  final FastSlidableController controller;

  /// Slide axis.
  /// 滑动轴。
  final Axis direction;

  /// Alignment used to pin the active pane.
  /// 用于钉住当前操作区的对齐。
  final Alignment alignment;

  /// Whether the visible pane is the start pane.
  /// 当前露出的是否为起始侧。
  final bool isStartPane;

  /// Reads the nearest scope, or `null`.
  /// 读取最近作用域；不存在时为 `null`。
  ///
  /// Set [listen] to `false` from `initState`.
  /// 在 `initState` 中请将 [listen] 设为 `false`。
  static FastSlidableScope? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<FastSlidableScope>();
    }
    return context
        .getElementForInheritedWidgetOfExactType<FastSlidableScope>()
        ?.widget as FastSlidableScope?;
  }

  @override
  bool updateShouldNotify(FastSlidableScope oldWidget) {
    return controller != oldWidget.controller ||
        direction != oldWidget.direction ||
        alignment != oldWidget.alignment ||
        isStartPane != oldWidget.isStartPane;
  }
}

/// Programmatic control for a [FastSlidable].
/// [FastSlidable] 的编程控制器。
///
/// Pass an external instance into [FastSlidable.controller]. The caller
/// disposes it. When omitted, the widget creates and disposes its own.
/// Replacing the instance only detaches listeners; the old external
/// controller is not disposed.
/// 通过 [FastSlidable.controller] 传入外部实例时，由调用方 [dispose]；
/// 未传入时由组件自建自毁。更换实例时只卸 listener，不 dispose 旧的外部控制器。
class FastSlidableController {
  /// Creates a controller. [vsync] drives open / close / dismiss animations.
  /// 创建控制器。[vsync] 驱动打开 / 关闭 / 删除动画。
  FastSlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync) {
    direction.addListener(_onDirectionChanged);
  }

  final AnimationController _animationController;

  /// Default open / close duration. Updated from [FastSlidableTheme].
  /// 默认开关时长。由 [FastSlidableTheme] 写入。
  Duration movementDuration = _kDefaultMovementDuration;

  /// Default open / close curve. Updated from [FastSlidableTheme].
  /// 默认开关曲线。由 [FastSlidableTheme] 写入。
  Curve movementCurve = _kDefaultMovementCurve;

  /// Whether the start pane can be revealed.
  /// 起始侧是否可露出。
  bool enableStartPane = true;

  /// Whether the end pane can be revealed.
  /// 末侧是否可露出。
  bool enableEndPane = true;

  /// Whether start is on the positive side (LTR or vertical).
  /// 起始侧是否在正方向（LTR 或竖直）。
  bool isLeftToRight = true;

  /// Start pane extent ratio.
  /// 起始侧占比。
  double startExtentRatio = kFastSlidableExtentRatio;

  /// End pane extent ratio.
  /// 末侧占比。
  double endExtentRatio = kFastSlidableExtentRatio;

  /// Active pane configurator.
  /// 当前操作区的比例配置。
  FastSlidableRatioConfigurator? get configurator => _configurator;
  FastSlidableRatioConfigurator? _configurator;
  set configurator(FastSlidableRatioConfigurator? value) {
    if (_configurator == value) {
      return;
    }
    _configurator = value;
    if (_replayEndGesture && value != null) {
      _replayEndGesture = false;
      value.handleEndGestureChanged();
    }
  }

  bool _replayEndGesture = false;
  bool _disposed = false;

  /// Animation of the absolute ratio `0..1`.
  /// 绝对比例 `0..1` 的动画。
  Animation<double> get animation => _animationController.view;

  /// Signed ratio in `-1..1`. Negative shows the end pane in LTR.
  /// 带符号比例 `-1..1`。LTR 下负值露出末侧。
  double get ratio => _animationController.value * direction.value;
  set ratio(double value) {
    final double newRatio = configurator?.normalizeRatio(value) ?? value;
    if (!_acceptRatio(newRatio) || newRatio == ratio) {
      return;
    }
    direction.value = newRatio.sign.toInt();
    _animationController.value = newRatio.abs();
  }

  /// End-of-drag notifier.
  /// 松手通知。
  final ValueNotifier<FastSlidableEndGesture?> endGesture =
      ValueNotifier<FastSlidableEndGesture?>(null);

  /// Dismiss-intent notifier. Used to know if a dismiss handler is mounted.
  /// 删除意图通知。用于判断删除处理器是否已挂载。
  final ValueNotifier<FastSlidableEndGesture?> dismissIntent =
      _HasListenersNotifier<FastSlidableEndGesture?>(null);

  /// Resize-after-dismiss notifier.
  /// 删除后收缩通知。
  final ValueNotifier<FastSlidableResizeRequest?> resizeRequest =
      ValueNotifier<FastSlidableResizeRequest?>(null);

  /// Visible pane type.
  /// 当前露出的操作区类型。
  final ValueNotifier<FastSlidablePaneType> paneType =
      ValueNotifier<FastSlidablePaneType>(FastSlidablePaneType.none);

  /// Movement sign: `-1`, `0`, or `1`.
  /// 位移符号：`-1`、`0` 或 `1`。
  final ValueNotifier<int> direction = ValueNotifier<int>(0);

  /// Whether a dismiss handler is listening.
  /// 是否已有删除处理器在监听。
  bool get isDismissReady =>
      (dismissIntent as _HasListenersNotifier<FastSlidableEndGesture?>)
          .hasListeners;

  /// Whether [close] is running.
  /// [close] 是否正在执行。
  bool get closing => _closing;
  bool _closing = false;

  bool get _enablePositivePane =>
      isLeftToRight ? enableStartPane : enableEndPane;

  bool get _enableNegativePane =>
      isLeftToRight ? enableEndPane : enableStartPane;

  bool _acceptRatio(double value) {
    return !_closing &&
        (value == 0 ||
            (value > 0 && _enablePositivePane) ||
            (value < 0 && _enableNegativePane));
  }

  void _onDirectionChanged() {
    final int multiplier = isLeftToRight ? 1 : -1;
    final int index = (direction.value * multiplier) + 1;
    paneType.value = FastSlidablePaneType.values[index];
  }

  /// Publishes an end gesture from the detector.
  /// 发布检测器产生的松手信号。
  void dispatchEndGesture(
    double? velocity,
    FastSlidableGestureKind kind,
  ) {
    final bool intoDisabledEnd = enableStartPane &&
        !enableEndPane &&
        direction.value == 0 &&
        kind == FastSlidableGestureKind.closing;
    final bool intoDisabledStart = !enableStartPane &&
        enableEndPane &&
        direction.value == 0 &&
        kind == FastSlidableGestureKind.opening;
    if (intoDisabledEnd || intoDisabledStart) {
      return;
    }

    if (velocity == null || velocity == 0) {
      endGesture.value = FastSlidableStillGesture(kind);
    } else if (velocity.sign == direction.value) {
      endGesture.value = FastSlidableOpeningGesture(velocity);
    } else {
      endGesture.value = FastSlidableClosingGesture(velocity.abs());
    }

    if (configurator == null) {
      _replayEndGesture = true;
    }
  }

  /// Closes the pane.
  /// 关闭操作区。
  Future<void> close({
    Duration? duration,
    Curve? curve,
  }) async {
    _closing = true;
    await _animationController.animateBack(
      0,
      duration: duration ?? movementDuration,
      curve: curve ?? movementCurve,
    );
    direction.value = 0;
    _closing = false;
  }

  /// Opens the currently visible pane to its extent.
  /// 将当前操作区打开到其占比。
  Future<void> openCurrent({
    Duration? duration,
    Curve? curve,
  }) {
    final double fallback = switch (paneType.value) {
      FastSlidablePaneType.start => startExtentRatio,
      FastSlidablePaneType.end => endExtentRatio,
      FastSlidablePaneType.none => kFastSlidableExtentRatio,
    };
    final double extent = configurator?.extentRatio ?? fallback;
    return openTo(extent, duration: duration, curve: curve);
  }

  /// Opens the start pane.
  /// 打开起始侧。
  Future<void> openStart({
    Duration? duration,
    Curve? curve,
  }) async {
    if (paneType.value != FastSlidablePaneType.start) {
      direction.value = isLeftToRight ? 1 : -1;
      ratio = 0;
    }
    return openTo(startExtentRatio, duration: duration, curve: curve);
  }

  /// Opens the end pane.
  /// 打开末侧。
  Future<void> openEnd({
    Duration? duration,
    Curve? curve,
  }) async {
    if (paneType.value != FastSlidablePaneType.end) {
      direction.value = isLeftToRight ? -1 : 1;
      ratio = 0;
    }
    return openTo(-endExtentRatio, duration: duration, curve: curve);
  }

  /// Opens to a signed [target] in `-1..1`.
  /// 打开到带符号的 [target]（`-1..1`）。
  Future<void> openTo(
    double target, {
    Duration? duration,
    Curve? curve,
  }) async {
    assert(target >= -1 && target <= 1);
    if (_closing) {
      return;
    }
    if (_animationController.value == 0) {
      ratio = 0.05 * target.sign;
    }
    return _animationController.animateTo(
      target.abs(),
      duration: duration ?? movementDuration,
      curve: curve ?? movementCurve,
    );
  }

  /// Animates to full extent, then publishes [request] for the resize step.
  /// 先滑满，再发布 [request] 做收缩。
  Future<void> dismiss(
    FastSlidableResizeRequest request, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (_disposed) {
      return;
    }
    await _animationController.animateTo(
      1,
      duration: duration ?? movementDuration,
      curve: curve ?? movementCurve,
    );
    if (_disposed) {
      return;
    }
    resizeRequest.value = request;
  }

  /// Disposes animation and notifiers created by this controller.
  /// 释放本控制器创建的动画与通知器。
  ///
  /// Only call this on a controller you created. The widget does not dispose
  /// an instance passed into [FastSlidable.controller].
  /// 只对你自己创建的实例调用。组件不会 dispose 传入
  /// [FastSlidable.controller] 的外部实例。
  void dispose() {
    _disposed = true;
    _animationController.stop();
    _animationController.dispose();
    direction.removeListener(_onDirectionChanged);
    direction.dispose();
    endGesture.dispose();
    dismissIntent.dispose();
    resizeRequest.dispose();
    paneType.dispose();
  }
}

class _HasListenersNotifier<T> extends ValueNotifier<T> {
  _HasListenersNotifier(super.value);

  @override
  bool get hasListeners => super.hasListeners;
}
