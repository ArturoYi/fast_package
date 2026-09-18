import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../controller/fast_slidable_controller.dart';
import '../widgets/fast_slidable_pane.dart';

/// Built-in pane reveal animations.
/// 内置操作区露出动画。
enum FastSlidableMotion {
  /// Actions sit behind the sliding child.
  /// 操作像在滑动项后面。
  behind,

  /// Actions enter like stacked drawers.
  /// 操作像抽屉依次滑出。
  drawer,

  /// Actions travel with the sliding child.
  /// 操作跟着滑动项一起移动。
  scroll,
}

/// Builds a custom pane motion.
/// 构建自定义操作区动画。
typedef FastSlidableMotionBuilder = Widget Function(
  BuildContext context,
  FastSlidablePaneData pane,
  FastSlidableController controller,
);

/// Host that maps [FastSlidableMotion] to a widget.
/// 将 [FastSlidableMotion] 映射为组件。
class FastSlidableMotionHost extends StatelessWidget {
  /// Creates a motion host.
  /// 创建动画宿主。
  const FastSlidableMotionHost({
    super.key,
    required this.motion,
  });

  /// Built-in motion.
  /// 内置动画。
  final FastSlidableMotion motion;

  @override
  Widget build(BuildContext context) {
    switch (motion) {
      case FastSlidableMotion.behind:
        return const _BehindMotion();
      case FastSlidableMotion.scroll:
        return const _ScrollMotion();
      case FastSlidableMotion.drawer:
        return const _DrawerMotion();
    }
  }
}

class _BehindMotion extends StatelessWidget {
  const _BehindMotion();

  @override
  Widget build(BuildContext context) {
    final FastSlidablePaneData pane = FastSlidablePane.of(context)!;
    return Flex(
      direction: pane.direction,
      children: pane.children,
    );
  }
}

class _ScrollMotion extends StatelessWidget {
  const _ScrollMotion();

  @override
  Widget build(BuildContext context) {
    final FastSlidablePaneData pane = FastSlidablePane.of(context)!;
    final FastSlidableController controller =
        FastSlidableScope.maybeOf(context)!.controller;
    final Offset startOffset = Offset(pane.alignment.x, pane.alignment.y);
    final Animation<Offset> animation = controller.animation
        .drive(CurveTween(curve: Interval(0, pane.extentRatio)))
        .drive(Tween<Offset>(begin: startOffset, end: Offset.zero));
    return SlideTransition(
      position: animation,
      child: const _BehindMotion(),
    );
  }
}

class _DrawerMotion extends StatelessWidget {
  const _DrawerMotion();

  @override
  Widget build(BuildContext context) {
    final FastSlidablePaneData pane = FastSlidablePane.of(context)!;
    final FastSlidableController controller =
        FastSlidableScope.maybeOf(context)!.controller;
    final Animation<double> animation = controller.animation
        .drive(CurveTween(curve: Interval(0, pane.extentRatio)));
    return _FlexEntranceTransition(
      mainAxisPosition: animation,
      direction: pane.direction,
      startToEnd: pane.fromStart,
      children: pane.children,
    );
  }
}

/// Grows the primary action as the drag goes past the pane extent.
/// 拖过操作区占比后，让主操作铺满。
class FastSlidableExpandMotion extends StatelessWidget {
  /// Creates an expand motion.
  /// 创建铺满动画。
  const FastSlidableExpandMotion({
    super.key,
    required this.primaryIndex,
  });

  /// Index of the action that grows.
  /// 会变宽的操作下标。
  final int primaryIndex;

  @override
  Widget build(BuildContext context) {
    final FastSlidablePaneData pane = FastSlidablePane.of(context)!;
    final FastSlidableController controller =
        FastSlidableScope.maybeOf(context)!.controller;
    final Animation<double> animation = controller.animation.drive(
      CurveTween(curve: Interval(pane.extentRatio, 1)),
    );
    return _FlexExitTransition(
      mainAxisExtent: animation,
      initialExtentRatio: pane.extentRatio,
      direction: pane.direction,
      startToEnd: pane.fromStart,
      primaryIndex: primaryIndex,
      children: pane.children,
    );
  }
}

class _FlexEntranceParentData extends FlexParentData {
  Tween<double>? mainAxisPosition;
}

class _FlexEntranceTransition extends MultiChildRenderObjectWidget {
  const _FlexEntranceTransition({
    required this.mainAxisPosition,
    required this.direction,
    required this.startToEnd,
    required super.children,
  });

  final Animation<double> mainAxisPosition;
  final Axis direction;
  final bool startToEnd;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFlexEntrance(
      mainAxisPosition: mainAxisPosition,
      direction: direction,
      startToEnd: startToEnd,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFlexEntrance renderObject,
  ) {
    renderObject
      ..mainAxisPosition = mainAxisPosition
      ..direction = direction
      ..startToEnd = startToEnd;
  }
}

class _RenderFlexEntrance extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FlexEntranceParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FlexEntranceParentData> {
  _RenderFlexEntrance({
    required Animation<double> mainAxisPosition,
    required Axis direction,
    required bool startToEnd,
  })  : _mainAxisPosition = mainAxisPosition,
        _direction = direction,
        _startToEnd = startToEnd;

  Animation<double> _mainAxisPosition;
  Animation<double> get mainAxisPosition => _mainAxisPosition;
  set mainAxisPosition(Animation<double> value) {
    if (_mainAxisPosition == value) {
      return;
    }
    if (attached) {
      _mainAxisPosition.removeListener(markNeedsOffsets);
      value.addListener(markNeedsOffsets);
    }
    _mainAxisPosition = value;
    markNeedsOffsets();
  }

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    markNeedsLayout();
  }

  bool _startToEnd;
  bool get startToEnd => _startToEnd;
  set startToEnd(bool value) {
    if (_startToEnd == value) {
      return;
    }
    _startToEnd = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FlexEntranceParentData) {
      child.parentData = _FlexEntranceParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _mainAxisPosition.addListener(markNeedsOffsets);
  }

  @override
  void detach() {
    _mainAxisPosition.removeListener(markNeedsOffsets);
    super.detach();
  }

  void markNeedsOffsets() {
    visitChildren(_updateChildOffset);
    markNeedsPaint();
  }

  void _updateChildOffset(RenderObject child) {
    final _FlexEntranceParentData parentData =
        child.parentData! as _FlexEntranceParentData;
    final double position =
        parentData.mainAxisPosition?.evaluate(_mainAxisPosition) ?? 0;
    parentData.offset = _direction == Axis.horizontal
        ? Offset(position, 0)
        : Offset(0, position);
  }

  int _totalFlex() {
    int total = 0;
    visitChildren((RenderObject child) {
      final _FlexEntranceParentData parentData =
          child.parentData! as _FlexEntranceParentData;
      total += parentData.flex ?? 1;
    });
    return total == 0 ? 1 : total;
  }

  @override
  void performLayout() {
    final int totalFlex = _totalFlex();
    double used = 0;
    size = constraints.biggest;
    visitChildren((RenderObject child) {
      final RenderBox box = child as RenderBox;
      final _FlexEntranceParentData parentData =
          box.parentData! as _FlexEntranceParentData;
      final double factor = (parentData.flex ?? 1) / totalFlex;
      late BoxConstraints inner;
      late double extent;
      late double begin;
      if (_direction == Axis.horizontal) {
        extent = constraints.maxWidth * factor;
        begin = startToEnd ? -extent : size.width;
        inner = BoxConstraints.tightFor(
          height: constraints.maxHeight,
          width: extent,
        );
      } else {
        extent = constraints.maxHeight * factor;
        begin = startToEnd ? -extent : size.height;
        inner = BoxConstraints.tightFor(
          height: extent,
          width: constraints.maxWidth,
        );
      }
      parentData.mainAxisPosition = Tween<double>(begin: begin, end: used);
      box.layout(inner);
      _updateChildOffset(box);
      used += extent;
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = startToEnd ? firstChild : lastChild;
    while (child != null) {
      final _FlexEntranceParentData parentData =
          child.parentData! as _FlexEntranceParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = startToEnd ? parentData.nextSibling : parentData.previousSibling;
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = startToEnd ? lastChild : firstChild;
    while (child != null) {
      final _FlexEntranceParentData parentData =
          child.parentData! as _FlexEntranceParentData;
      context.paintChild(child, parentData.offset + offset);
      child =
          startToEnd ? parentData.previousSibling : parentData.nextSibling;
    }
  }
}

class _FlexExitParentData extends FlexParentData {}

class _FlexExitTransition extends MultiChildRenderObjectWidget {
  const _FlexExitTransition({
    required this.mainAxisExtent,
    required this.direction,
    required this.startToEnd,
    required this.initialExtentRatio,
    required this.primaryIndex,
    required super.children,
  });

  final Animation<double> mainAxisExtent;
  final Axis direction;
  final bool startToEnd;
  final double initialExtentRatio;
  final int primaryIndex;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFlexExit(
      mainAxisExtent: mainAxisExtent,
      direction: direction,
      startToEnd: startToEnd,
      initialExtentRatio: initialExtentRatio,
      primaryIndex: primaryIndex,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderFlexExit renderObject) {
    renderObject
      ..mainAxisExtent = mainAxisExtent
      ..direction = direction
      ..startToEnd = startToEnd
      ..initialExtentRatio = initialExtentRatio
      ..primaryIndex = primaryIndex;
  }
}

class _RenderFlexExit extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FlexExitParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FlexExitParentData> {
  _RenderFlexExit({
    required Animation<double> mainAxisExtent,
    required Axis direction,
    required bool startToEnd,
    required double initialExtentRatio,
    required int primaryIndex,
  })  : _mainAxisExtent = mainAxisExtent,
        _direction = direction,
        _startToEnd = startToEnd,
        _initialExtentRatio = initialExtentRatio,
        _primaryIndex = primaryIndex;

  Animation<double> _mainAxisExtent;
  Animation<double> get mainAxisExtent => _mainAxisExtent;
  set mainAxisExtent(Animation<double> value) {
    if (_mainAxisExtent == value) {
      return;
    }
    if (attached) {
      _mainAxisExtent.removeListener(markNeedsLayout);
      value.addListener(markNeedsLayout);
    }
    _mainAxisExtent = value;
    markNeedsLayout();
  }

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  bool _startToEnd;
  bool get startToEnd => _startToEnd;
  set startToEnd(bool value) {
    if (_startToEnd != value) {
      _startToEnd = value;
      markNeedsLayout();
    }
  }

  double _initialExtentRatio;
  double get initialExtentRatio => _initialExtentRatio;
  set initialExtentRatio(double value) {
    if (_initialExtentRatio != value) {
      _initialExtentRatio = value;
      markNeedsLayout();
    }
  }

  int _primaryIndex;
  int get primaryIndex => _primaryIndex;
  set primaryIndex(int value) {
    if (_primaryIndex != value) {
      _primaryIndex = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FlexExitParentData) {
      child.parentData = _FlexExitParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _mainAxisExtent.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _mainAxisExtent.removeListener(markNeedsLayout);
    super.detach();
  }

  int _totalFlex() {
    int total = 0;
    visitChildren((RenderObject child) {
      final _FlexExitParentData parentData =
          child.parentData! as _FlexExitParentData;
      total += parentData.flex ?? 1;
    });
    return total == 0 ? 1 : total;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final double totalMain =
        _direction == Axis.horizontal ? size.width : size.height;
    final int totalFlex = _totalFlex();
    final double t = _mainAxisExtent.value.clamp(0.0, 1.0);
    double usedInitial = 0;
    int index = 0;
    RenderBox? child = startToEnd ? firstChild : lastChild;
    while (child != null) {
      final _FlexExitParentData parentData =
          child.parentData! as _FlexExitParentData;
      final int visualIndex = startToEnd ? index : (childCount - 1 - index);
      final bool isPrimary = visualIndex == primaryIndex;
      final double factor = (parentData.flex ?? 1) / totalFlex * initialExtentRatio;
      final double initialExtent = totalMain * factor;
      final double extent = isPrimary
          ? Tween<double>(
              begin: initialExtent,
              end: totalMain - (usedInitial - (isPrimary ? 0 : 0)),
            ).transform(t)
          : Tween<double>(begin: initialExtent, end: 0).transform(t);
      final double safeExtent = extent.clamp(0.0, totalMain);
      late BoxConstraints inner;
      if (_direction == Axis.horizontal) {
        final double begin = startToEnd
            ? usedInitial * (1 - t)
            : totalMain - usedInitial * (1 - t) - safeExtent;
        parentData.offset = Offset(begin.clamp(0.0, totalMain), 0);
        inner = BoxConstraints.tightFor(
          height: constraints.maxHeight,
          width: safeExtent,
        );
      } else {
        final double begin = startToEnd
            ? usedInitial * (1 - t)
            : totalMain - usedInitial * (1 - t) - safeExtent;
        parentData.offset = Offset(0, begin.clamp(0.0, totalMain));
        inner = BoxConstraints.tightFor(
          height: safeExtent,
          width: constraints.maxWidth,
        );
      }
      child.layout(inner);
      usedInitial += initialExtent;
      index += 1;
      child = startToEnd ? parentData.nextSibling : parentData.previousSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = startToEnd ? firstChild : lastChild;
    while (child != null) {
      final _FlexExitParentData parentData =
          child.parentData! as _FlexExitParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = startToEnd ? parentData.nextSibling : parentData.previousSibling;
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = startToEnd ? lastChild : firstChild;
    while (child != null) {
      final _FlexExitParentData parentData =
          child.parentData! as _FlexExitParentData;
      context.paintChild(child, parentData.offset + offset);
      child =
          startToEnd ? parentData.previousSibling : parentData.nextSibling;
    }
  }
}
