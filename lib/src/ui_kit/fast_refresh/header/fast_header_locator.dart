part of '../fast_refresh.dart';

/// 把 Header 放进列表内部（通常作为第一项）。
///
/// Header 的 [FastRefreshIndicator.position] 需为
/// [FastRefreshIndicatorPosition.locator] 或 `custom`。
class FastHeaderLocator extends StatelessWidget {
  /// 是否作为 Sliver 使用。
  final bool _isSliver;

  /// 始终保留的绘制范围，见 [SliverGeometry.paintExtent]。
  final double paintExtent;

  /// 为 `true` 时占位 extent 视为 0，由自定义 RenderObject 负责绘制偏移。
  final bool clearExtent;

  /// 用在普通 Box 布局中。
  const FastHeaderLocator({
    super.key,
    this.paintExtent = 0,
    this.clearExtent = true,
  }) : _isSliver = false;

  /// 用在 [CustomScrollView] 等 Sliver 列表中。
  const FastHeaderLocator.sliver({
    super.key,
    this.paintExtent = 0,
    this.clearExtent = true,
  }) : _isSliver = true;

  @override
  Widget build(BuildContext context) {
    final headerNotifier = FastRefresh.of(context).headerNotifier;
    assert(
        headerNotifier.iPosition == FastRefreshIndicatorPosition.locator ||
            headerNotifier.iPosition == FastRefreshIndicatorPosition.custom,
        'Cannot use FastHeaderLocator when header position is not FastRefreshIndicatorPosition.locator.');
    return ValueListenableBuilder(
      valueListenable: headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (headerNotifier.axis != null) {
          final axis = headerNotifier.axis!;
          final axisDirection = headerNotifier.axisDirection!;
          // 同步安全区，计入实际触发距离。
          final safePadding = MediaQuery.of(context).padding;
          headerNotifier._safeOffset = axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? safePadding.top
                  : safePadding.bottom
              : axisDirection == AxisDirection.right
                  ? safePadding.left
                  : safePadding.right;
        }
        final headerWidget = headerNotifier._build(context);
        if (!clearExtent) {
          return _isSliver
              ? SliverToBoxAdapter(
                  child: headerWidget,
                )
              : headerWidget;
        }
        return _FastHeaderLocatorRenderWidget(
          isSliver: _isSliver,
          paintExtent: paintExtent,
          child: headerWidget,
        );
      },
    );
  }
}

/// 按 [isSliver] 创建 Box 或 Sliver RenderObject。
class _FastHeaderLocatorRenderWidget extends SingleChildRenderObjectWidget {
  /// 是否创建 Sliver RenderObject。
  final bool isSliver;

  /// 始终保留的绘制范围。
  final double paintExtent;

  const _FastHeaderLocatorRenderWidget({
    // ignore: unused_element_parameter
    super.key,
    required super.child,
    required this.isSliver,
    required this.paintExtent,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => isSliver
      ? _FastHeaderLocatorRenderSliver(
          context: context,
          paintExtent: paintExtent,
        )
      : _FastHeaderLocatorRenderBox(
          context: context,
          paintExtent: paintExtent,
        );
}

/// Box 布局下的 Header 定位：把指示器画在列表上方外侧。
class _FastHeaderLocatorRenderBox extends RenderProxyBox {
  /// 用于读取 [FastRefreshData]。
  final BuildContext context;

  /// 始终保留的绘制范围。
  final double paintExtent;

  _FastHeaderLocatorRenderBox({
    required this.context,
    RenderBox? child,
    required this.paintExtent,
  }) : super(child);

  @override
  final bool needsCompositing = true;

  /// 占位尽量为 0；有偏移时给极小 extent，保证能进入 [paint]。
  @override
  void performLayout() {
    final headerNotifier = FastRefresh.of(context).headerNotifier;
    final axis = headerNotifier.axis;
    final double extend = paintExtent == 0
        ? (headerNotifier.offset == 0 ? 0 : 0.0000000001)
        : paintExtent;
    if (axis == null) {
      size = constraints.smallest;
    } else {
      size = Size(
        constraints
            .constrainWidth(axis == Axis.vertical ? double.infinity : extend),

        // 占位不能为 0，否则 RenderObject 不会进入 paint。
        constraints
            .constrainHeight(axis == Axis.vertical ? extend : double.infinity),
      );
    }
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
  }

  /// 按当前越界偏移把 Header 画到列表上方 / 左侧外侧。
  @override
  void paint(PaintingContext context, Offset offset) {
    final headerNotifier = FastRefresh.of(this.context).headerNotifier;
    final axis = headerNotifier.axis;
    final axisDirection = headerNotifier.axisDirection;
    final extend = headerNotifier.offset;
    Offset mOffset;
    if (axis == null || axisDirection == null) {
      mOffset = offset;
    } else {
      final double dx = axis == Axis.vertical
          ? 0
          : axisDirection == AxisDirection.right
              ? -extend
              : 0;
      final double dy = axis == Axis.horizontal
          ? 0
          : axisDirection == AxisDirection.down
              ? -extend
              : 0;
      mOffset = Offset(dx, dy);
    }
    if (child != null) {
      context.paintChild(child!, mOffset);
    }
  }
}

/// Sliver 布局下的 Header 定位。
class _FastHeaderLocatorRenderSliver extends RenderSliverSingleBoxAdapter {
  /// 用于读取 [FastRefreshData]。
  final BuildContext context;

  /// 始终保留的绘制范围。
  final double paintExtent;

  _FastHeaderLocatorRenderSliver({
    required this.context,
    required this.paintExtent,
    // ignore: unused_element_parameter
    super.child,
  });

  /// scrollExtent 为 0，把 Header 画到视口外侧，不占列表滚动范围。
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0, to: childExtent);
    // final double cacheExtent =
    //     calculateCacheOffset(constraints, from: 0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0);
    final headerNotifier = FastRefresh.of(context).headerNotifier;
    geometry = SliverGeometry(
      scrollExtent: 0,
      paintExtent: math.min(childExtent, paintExtent),
      // bouncing 时把绘制原点挪到视口外侧，指示器叠在内容上方。
      paintOrigin: (constraints.axisDirection == AxisDirection.down ||
                  constraints.axisDirection == AxisDirection.right) &&
              !headerNotifier.clamping
          ? -headerNotifier.offset
          : 0,
      // 缓存范围与绘制范围对齐，避免额外预取。
      cacheExtent: math.min(childExtent, paintExtent),
      maxPaintExtent: math.max(childExtent, paintExtent),
      hitTestExtent: math.max(childExtent, paintedChildSize),
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0,
      visible: true,
    );
    setChildParentData(child!, constraints.copyWith(), geometry!);
  }
}
