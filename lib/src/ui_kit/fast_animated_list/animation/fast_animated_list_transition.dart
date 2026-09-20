import 'package:flutter/widgets.dart';

import 'fast_list_stagger.dart';

/// Visual recipe for insert / first-frame entrance.
/// 插入 / 首屏入场的视觉配方。
enum FastListEntrance {
  /// Size (list) or no extra motion (grid).
  /// 列表只收放高度；网格不再加位移。
  none,

  /// Fade only.
  /// 只淡入。
  fade,

  /// Slide from [FastListStaggerSlot.slideOffset].
  /// 从 [FastListStaggerSlot.slideOffset] 滑入。
  slide,

  /// Fade + slide (Material-style default).
  /// 淡入 + 滑动（默认，贴近 Material）。
  fadeSlide,

  /// Fade + scale (better on grids).
  /// 淡入 + 缩放（网格更合适）。
  scale,
}

/// Applies [SliverAnimatedList] animation without leaking [CurvedAnimation]s.
/// 把 AnimatedList 的 animation 套到 child 上，且不在 build 里泄漏 [CurvedAnimation]。
class FastListMutationTransition extends StatefulWidget {
  /// Creates a mutation transition.
  /// 创建增删过渡。
  const FastListMutationTransition({
    super.key,
    required this.animation,
    required this.axis,
    required this.grid,
    required this.entrance,
    required this.curve,
    required this.slideOffset,
    this.intervalBegin = 0,
    required this.child,
  });

  /// 0→1 from [SliverAnimatedList] / remove builder.
  /// AnimatedList / 删除 builder 给的 0→1。
  final Animation<double> animation;

  /// Main axis of the list.
  /// 列表主轴。
  final Axis axis;

  /// Whether the host is a grid.
  /// 是否网格。
  final bool grid;

  /// Extra motion on top of size / fade.
  /// 在收放 / 淡入之上的附加动作。
  final FastListEntrance entrance;

  /// Curve applied once and disposed with the State.
  /// 曲线只建一次，随 State dispose。
  final Curve curve;

  /// Slide pixels when [entrance] includes slide.
  /// 包含 slide 时的像素位移。
  final double slideOffset;

  /// Start of the visual interval in `0..1`. Used to stagger a batch insert.
  /// 视觉 Interval 起点（`0..1`），用来错开同一批发插入。
  final double intervalBegin;

  /// Child to transition.
  /// 要过渡的子节点。
  final Widget child;

  @override
  State<FastListMutationTransition> createState() =>
      _FastListMutationTransitionState();
}

class _FastListMutationTransitionState
    extends State<FastListMutationTransition> {
  late CurvedAnimation _curved;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant FastListMutationTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.curve != widget.curve ||
        oldWidget.axis != widget.axis ||
        oldWidget.slideOffset != widget.slideOffset ||
        oldWidget.intervalBegin != widget.intervalBegin) {
      _curved.dispose();
      _bind();
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  void _bind() {
    _curved = CurvedAnimation(
      parent: widget.animation,
      curve: _resolvedCurve(),
    );
    final Offset begin = widget.axis == Axis.vertical
        ? Offset(0, widget.slideOffset)
        : Offset(widget.slideOffset, 0);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(_curved);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(_curved);
  }

  Curve _resolvedCurve() {
    if (widget.intervalBegin <= 0) {
      return widget.curve;
    }
    return Interval(
      widget.intervalBegin.clamp(0.0, 0.999),
      1,
      curve: widget.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.entrance == FastListEntrance.fade ||
        widget.entrance == FastListEntrance.fadeSlide ||
        widget.entrance == FastListEntrance.scale) {
      child = FadeTransition(opacity: _curved, child: child);
    }

    if (widget.entrance == FastListEntrance.slide ||
        widget.entrance == FastListEntrance.fadeSlide) {
      child = AnimatedBuilder(
        animation: _slide,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(offset: _slide.value, child: child);
        },
        child: child,
      );
    }

    if (widget.entrance == FastListEntrance.scale || widget.grid) {
      child = ScaleTransition(scale: _scale, child: child);
    } else {
      child = SizeTransition(
        sizeFactor: _curved,
        axis: widget.axis,
        child: child,
      );
    }

    return child;
  }
}

/// First-frame stagger slot. Captures whether to play once.
/// 首屏错开槽位。是否播放只在第一次依赖时捕获。
class FastListStaggerSlot extends StatefulWidget {
  /// Creates a stagger slot.
  /// 创建错开槽位。
  const FastListStaggerSlot({
    super.key,
    required this.position,
    required this.entrance,
    required this.slideOffset,
    required this.child,
  });

  /// Index used for delay.
  /// 用于计算 delay 的下标。
  final int position;

  /// Entrance recipe when this slot plays.
  /// 本槽位播放时的入场配方。
  final FastListEntrance entrance;

  /// Slide pixels.
  /// 滑动像素。
  final double slideOffset;

  /// Child.
  /// 子节点。
  final Widget child;

  @override
  State<FastListStaggerSlot> createState() => _FastListStaggerSlotState();
}

class _FastListStaggerSlotState extends State<FastListStaggerSlot> {
  bool _configured = false;
  bool _play = false;
  CurvedAnimation? _interval;
  Animation<Offset>? _slide;
  Animation<double>? _scale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configured) {
      return;
    }
    _configured = true;
    final FastStaggerScope? scope = FastStaggerScope.maybeOf(context);
    _play = scope != null &&
        scope.stagger.isEnabled &&
        !scope.limitNewItems &&
        widget.entrance != FastListEntrance.none;
    if (_play) {
      final (double start, double end) =
          scope!.stagger.intervalFor(widget.position);
      _interval = CurvedAnimation(
        parent: scope.animation,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
      final Offset begin = Offset(0, widget.slideOffset);
      _slide =
          Tween<Offset>(begin: begin, end: Offset.zero).animate(_interval!);
      _scale = Tween<double>(begin: 0.92, end: 1).animate(_interval!);
    }
  }

  @override
  void dispose() {
    _interval?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_play || _interval == null) {
      return widget.child;
    }

    Widget child = widget.child;
    final FastListEntrance entrance = widget.entrance;

    if (entrance == FastListEntrance.fade ||
        entrance == FastListEntrance.fadeSlide ||
        entrance == FastListEntrance.scale) {
      child = FadeTransition(opacity: _interval!, child: child);
    }
    if (entrance == FastListEntrance.slide ||
        entrance == FastListEntrance.fadeSlide) {
      child = AnimatedBuilder(
        animation: _slide!,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(offset: _slide!.value, child: child);
        },
        child: child,
      );
    }
    if (entrance == FastListEntrance.scale) {
      child = ScaleTransition(scale: _scale!, child: child);
    }
    return child;
  }
}

/// Hosts a shared AnimationController and skips entrance after the first frame.
/// 持有共用的 AnimationController，并在首帧后限制滚入再播。
class FastStagger extends StatefulWidget {
  /// Wraps [child] with a stagger clock.
  /// 给 [child] 套上错开时钟。
  const FastStagger({
    super.key,
    this.stagger = const FastListStagger.list(),
    this.entrance = FastListEntrance.fadeSlide,
    this.slideOffset = 50,
    required this.child,
  });

  /// Stagger settings.
  /// 错开配置。
  final FastListStagger stagger;

  /// Default entrance for [item] / [children].
  /// [item] / [children] 的默认入场。
  final FastListEntrance entrance;

  /// Slide pixels.
  /// 滑动像素。
  final double slideOffset;

  /// Typically a [Column], [Row], or scrollable.
  /// 通常是 [Column]、[Row] 或可滚动列表。
  final Widget child;

  /// Wraps one child with the nearest [FastStagger] clock.
  /// 用最近的 [FastStagger] 时钟包一层。
  static Widget item({
    Key? key,
    required int position,
    FastListEntrance? entrance,
    double? slideOffset,
    required Widget child,
  }) {
    return _FastStaggerItem(
      key: key,
      position: position,
      entrance: entrance,
      slideOffset: slideOffset,
      child: child,
    );
  }

  /// Maps [children] to staggered slots (Column / Row helper).
  /// 把 [children] 映射成错开槽位（Column / Row 辅助）。
  static List<Widget> children({
    FastListStagger stagger = const FastListStagger.list(),
    FastListEntrance entrance = FastListEntrance.fadeSlide,
    double slideOffset = 50,
    required List<Widget> children,
  }) {
    return <Widget>[
      for (int i = 0; i < children.length; i++)
        FastStagger.item(
          position: i,
          entrance: entrance,
          slideOffset: slideOffset,
          child: children[i],
        ),
    ];
  }

  @override
  State<FastStagger> createState() => _FastStaggerState();
}

class _FastStaggerState extends State<FastStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _limitNewItems = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.stagger.isEnabled
          ? widget.stagger.totalDuration
          : const Duration(milliseconds: 1),
    );
    if (widget.stagger.isEnabled) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _limitNewItems = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FastStaggerScope(
      animation: _controller,
      stagger: widget.stagger,
      limitNewItems: _limitNewItems,
      child: widget.child,
    );
  }
}

class _FastStaggerItem extends StatelessWidget {
  const _FastStaggerItem({
    super.key,
    required this.position,
    required this.entrance,
    required this.slideOffset,
    required this.child,
  });

  final int position;
  final FastListEntrance? entrance;
  final double? slideOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final FastStagger? host =
        context.findAncestorWidgetOfExactType<FastStagger>();
    return FastListStaggerSlot(
      position: position,
      entrance: entrance ?? host?.entrance ?? FastListEntrance.fadeSlide,
      slideOffset: slideOffset ?? host?.slideOffset ?? 50,
      child: child,
    );
  }
}
