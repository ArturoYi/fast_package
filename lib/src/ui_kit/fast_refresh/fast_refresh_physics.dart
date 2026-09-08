part of 'fast_refresh.dart';

/// 越界摩擦系数。
///
/// 入参是「已越界距离 / 视口尺寸」，返回值越小，越界越「涩」。
typedef FastRefreshFrictionFactor = double Function(double overscrollFraction);

/// FastRefresh 的滚动物理：越界摩擦、ready 弹簧、边界钳制、惯性回弹。
class _FRScrollPhysics extends BouncingScrollPhysics {
  /// 创建物理并与 Header / Footer notifier 互绑。
  _FRScrollPhysics({
    super.parent = const AlwaysScrollableScrollPhysics(),
    required this.userOffsetNotifier,
    required this.headerNotifier,
    required this.footerNotifier,
    physics.SpringDescription? spring,
    FastRefreshFrictionFactor? frictionFactor,
  })  : _spring = spring,
        _frictionFactor = frictionFactor {
    headerNotifier._bindPhysics(this);
    footerNotifier._bindPhysics(this);
    _headerSimulationCreationState =
        ValueNotifier(_BallisticSimulationCreationState(
      mode: headerNotifier.mode,
      offset: headerNotifier.offset,
      actualTriggerOffset: headerNotifier.actualTriggerOffset,
    ));
    _footerSimulationCreationState =
        ValueNotifier(_BallisticSimulationCreationState(
      mode: footerNotifier.mode,
      offset: footerNotifier.offset,
      actualTriggerOffset: footerNotifier.actualTriggerOffset,
    ));
  }

  /// 链式继承父物理，并继续绑定同一对 Header / Footer notifier。
  @override
  _FRScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _FRScrollPhysics(
      parent: buildParent(ancestor),
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
      spring: _spring,
      frictionFactor: _frictionFactor,
    );
  }

  /// 用户是否正在拖拽。`true` 表示手指未离开。
  final ValueNotifier<bool> userOffsetNotifier;

  /// Header 状态机。
  final FastRefreshHeaderNotifier headerNotifier;

  /// Footer 状态机。
  final FastRefreshFooterNotifier footerNotifier;

  /// 惯性模拟使用的弹簧；未指定时用 Header / Footer / 系统默认。
  final physics.SpringDescription? _spring;

  /// 上次创建惯性模拟时的 Header 状态，用于判断是否需要重建模拟。
  late final ValueNotifier<_BallisticSimulationCreationState>
      _headerSimulationCreationState;
  /// 上次创建惯性模拟时的 Footer 状态。
  late final ValueNotifier<_BallisticSimulationCreationState>
      _footerSimulationCreationState;

  /// 当前应使用的弹簧：ready 态优先用 [FastRefreshIndicator.readySpringBuilder]。
  @override
  physics.SpringDescription get spring {
    if (headerNotifier.outOfRange) {
      if (headerNotifier._mode == FastRefreshMode.ready &&
          headerNotifier.readySpringBuilder != null) {
        return headerNotifier.readySpringBuilder!(
          mode: headerNotifier._mode,
          offset: headerNotifier._offset,
          actualTriggerOffset: headerNotifier.actualTriggerOffset,
          velocity: headerNotifier.velocity,
        );
      } else if (headerNotifier._spring != null) {
        return headerNotifier._spring!;
      }
    }
    if (footerNotifier.outOfRange) {
      if (footerNotifier._mode == FastRefreshMode.ready &&
          footerNotifier.readySpringBuilder != null) {
        return footerNotifier.readySpringBuilder!(
          mode: footerNotifier._mode,
          offset: footerNotifier._offset,
          actualTriggerOffset: footerNotifier.actualTriggerOffset,
          velocity: footerNotifier.velocity,
        );
      } else if (footerNotifier._spring != null) {
        return footerNotifier._spring!;
      }
    }
    return _spring ?? super.spring;
  }

  /// 越界摩擦；未指定时用 Header / Footer / 系统默认。
  final FastRefreshFrictionFactor? _frictionFactor;

  /// 当前越界侧的摩擦；未指定时回退 [BouncingScrollPhysics]。
  @override
  double frictionFactor(double overscrollFraction) {
    FastRefreshFrictionFactor factor;
    if (headerNotifier._frictionFactor != null && headerNotifier.outOfRange) {
      factor = headerNotifier._frictionFactor!;
    } else if (footerNotifier._frictionFactor != null &&
        footerNotifier.outOfRange) {
      factor = footerNotifier._frictionFactor!;
    } else {
      factor = _frictionFactor ?? super.frictionFactor;
    }
    return factor.call(overscrollFraction);
  }

  /// 用户拖拽位移：越界后按摩擦折算，二楼锁定时改用二楼坐标系。
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 用户开始拖拽。
    userOffsetNotifier.value = true;
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // 未越界则原样传递。clamping 时以指示器 offset 为准。
    if (!(position.outOfRange ||
        (headerNotifier.clamping && headerNotifier.outOfRange) ||
        (footerNotifier.clamping && footerNotifier.outOfRange))) {
      return offset;
    }
    // clamping 时把指示器偏移折算进实际像素。
    double pixels = position.pixels;
    if (headerNotifier.clamping && headerNotifier.outOfRange) {
      pixels = position.pixels - headerNotifier._offset;
    }
    if (footerNotifier.clamping && footerNotifier.outOfRange) {
      pixels = position.pixels + footerNotifier._offset;
    }
    double minScrollExtent = position.minScrollExtent;
    double maxScrollExtent = position.maxScrollExtent;

    if (headerNotifier.secondaryLocked) {
      // Header 二楼锁定时的坐标系。
      pixels = headerNotifier.secondaryDimension +
          (headerNotifier.secondaryDimension + position.pixels);
      minScrollExtent = 0;
      maxScrollExtent = headerNotifier.secondaryDimension;
    }

    if (footerNotifier.secondaryLocked) {
      // Footer 二楼锁定时的坐标系。
      pixels = position.pixels -
          footerNotifier.secondaryDimension -
          position.maxScrollExtent;
      minScrollExtent = 0;
      maxScrollExtent = footerNotifier.secondaryDimension;
    }

    final double overscrollPastStart = math.max(minScrollExtent - pixels, 0.0);
    final double overscrollPastEnd = math.max(pixels - maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    // NestedScrollView 内层可能拿不到正确视口，改用外层或 context 尺寸。
    double viewportDimension = position.viewportDimension;
    if ((headerNotifier.isNested && position.isNestedInner)) {
      if (headerNotifier._viewportDimension != null) {
        viewportDimension = headerNotifier._viewportDimension!;
      } else {
        viewportDimension = (position.axis == Axis.vertical
                ? headerNotifier.vsync.context.size?.height
                : headerNotifier.vsync.context.size?.width) ??
            viewportDimension;
      }
    }

    // 往回松时比继续外拉更「滑」，避免越界回弹发涩。
    final double friction = easing
        ? frictionFactor((overscrollPast - offset.abs()) / viewportDimension)
        : frictionFactor(overscrollPast / viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  /// 把用户位移按摩擦系数折算：越界段先乘 [gamma]，剩余按原位移累加。
  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  /// 钳制越界：返回值是「不交给列表」的像素；同时把真实位置同步给指示器。
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // 首次或轴变化时记下当前轴，供指示器布局使用。
    if (headerNotifier._axis != position.axis ||
        headerNotifier._axisDirection != position.axisDirection) {
      headerNotifier._axis = position.axis;
      headerNotifier._axisDirection = position.axisDirection;
    }
    if (footerNotifier._axis != position.axis ||
        footerNotifier._axisDirection != position.axisDirection) {
      footerNotifier._axis = position.axis;
      footerNotifier._axisDirection = position.axisDirection;
    }
    // 需要从本次位移里扣掉、不交给列表的部分。
    double bounds = 0;

    // —— Header 边界 ——
    if (headerNotifier.clamping == true) {
      if (value < position.minScrollExtent &&
          (position.minScrollExtent < position.pixels ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  position.minScrollExtent == position.pixels))) {
        // 碰到顶部边缘，钳住列表。
        _updateIndicatorOffset(position, 0, value);
        return value - position.minScrollExtent;
      } else if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) {
        // 顶部反向回拉。
        bounds = value - position.pixels;
      } else if (headerNotifier._offset > 0 &&
          !(headerNotifier.modeLocked || headerNotifier.secondaryLocked)) {
        // Header 仍可见，列表不跟着走。
        bounds = value - position.pixels;
        // 越界上限。
      }
    } else {
      // 越界上限。
      if (headerNotifier.actualMaxOverOffset != double.infinity &&
          value < -headerNotifier.actualMaxOverOffset) {
        _updateIndicatorOffset(
            position, -headerNotifier.actualMaxOverOffset, value);
        return (value + headerNotifier.actualMaxOverOffset) -
            position.minScrollExtent;
      }
      // 不允许越界时钳在顶部。
      if (!(headerNotifier.hitOver || headerNotifier.modeLocked) &&
          headerNotifier.mode != FastRefreshMode.ready &&
          value < position.minScrollExtent &&
          (position.minScrollExtent < position.pixels ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  position.minScrollExtent == position.pixels))) {
        _updateIndicatorOffset(position, 0, value);
        return value - position.minScrollExtent;
      }
      // 无限滚动：钳在触发位。
      if (headerNotifier._isSupportAxis &&
          (!headerNotifier.infiniteHitOver ||
              (!headerNotifier.hitOver && headerNotifier.modeLocked)) &&
          (headerNotifier._canProcess || headerNotifier.noMoreLocked) &&
          (value + headerNotifier.actualTriggerOffset) <
              position.minScrollExtent &&
          (position.minScrollExtent <
                  (position.pixels + headerNotifier.actualTriggerOffset) ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  position.minScrollExtent ==
                      (position.pixels +
                          headerNotifier.actualTriggerOffset)))) {
        _updateIndicatorOffset(
            position, -headerNotifier.actualTriggerOffset, value);
        return (value + headerNotifier.actualTriggerOffset) -
            position.minScrollExtent;
      }
      // 禁止 ready 弹簧越过触发位。
      if (headerNotifier._releaseOffset > 0 &&
          headerNotifier._mode == FastRefreshMode.ready &&
          !headerNotifier._indicator.springRebound &&
          -value < headerNotifier.actualTriggerOffset) {
        _updateIndicatorOffset(
            position, -headerNotifier.actualTriggerOffset, value);
        return headerNotifier.actualTriggerOffset +
            value -
            position.minScrollExtent;
      }
      // 不能越过二楼高度。
      if (headerNotifier.hasSecondary) {
        if (value < position.pixels &&
            position.pixels <=
                position.minScrollExtent - headerNotifier.secondaryDimension) {
          // 二楼反向回拉。
          bounds = value - position.pixels;
        } else if (value + headerNotifier.secondaryDimension <
                position.minScrollExtent &&
            position.minScrollExtent <
                position.pixels + headerNotifier.secondaryDimension) {
          // 碰到二楼顶部。
          _updateIndicatorOffset(
              position, -headerNotifier.secondaryDimension, value);
          return value +
              headerNotifier.secondaryDimension -
              position.minScrollExtent;
        }
      }
    }

    // —— Footer 边界 ——
    if (footerNotifier.clamping == true) {
      if ((position.pixels < position.maxScrollExtent ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  position.pixels == position.maxScrollExtent)) &&
          position.maxScrollExtent < value) {
        // 碰到底部边缘，钳住列表。
        _updateIndicatorOffset(position, position.maxScrollExtent, value);
        return value - position.maxScrollExtent;
      } else if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) {
        // 底部继续外拉。
        bounds = value - position.pixels;
      } else if (footerNotifier._offset > 0 &&
          !(footerNotifier.modeLocked || footerNotifier.secondaryLocked)) {
        // Footer 仍可见，列表不跟着走。
        bounds = value - position.pixels;
      }
    } else {
      // 越界上限。
      if (footerNotifier.actualMaxOverOffset != double.infinity &&
          position.maxScrollExtent <
              value - footerNotifier.actualMaxOverOffset) {
        _updateIndicatorOffset(
            position,
            position.maxScrollExtent + footerNotifier.actualMaxOverOffset,
            value);
        return (value - footerNotifier.actualMaxOverOffset) -
            position.maxScrollExtent;
      }
      // 不允许越界时钳在底部。
      if (!(footerNotifier.hitOver || footerNotifier.modeLocked) &&
          footerNotifier.mode != FastRefreshMode.ready &&
          (position.pixels < position.maxScrollExtent ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  position.pixels == position.maxScrollExtent)) &&
          position.maxScrollExtent < value) {
        _updateIndicatorOffset(position, position.maxScrollExtent, value);
        return value - position.maxScrollExtent;
      }
      // 无限滚动：钳在触发位。
      if (footerNotifier._isSupportAxis &&
          !(footerNotifier.infiniteOffset != null &&
              position.maxScrollExtent <= position.minScrollExtent) &&
          (!footerNotifier.infiniteHitOver ||
              !footerNotifier.hitOver && footerNotifier.modeLocked) &&
          (footerNotifier._canProcess || footerNotifier.noMoreLocked) &&
          ((position.pixels - footerNotifier.actualTriggerOffset) <
                  position.maxScrollExtent ||
              // NestedScrollView：停在边缘且已松手时也视为碰到边界。
              (!userOffsetNotifier.value &&
                  (position.pixels - footerNotifier.actualTriggerOffset) ==
                      position.maxScrollExtent)) &&
          position.maxScrollExtent <
              (value - footerNotifier.actualTriggerOffset)) {
        _updateIndicatorOffset(
            position,
            position.maxScrollExtent + footerNotifier.actualTriggerOffset,
            value);
        return (value - footerNotifier.actualTriggerOffset) -
            position.maxScrollExtent;
      }
      // 禁止 ready 弹簧越过触发位。
      if (footerNotifier._releaseOffset > 0 &&
          footerNotifier._mode == FastRefreshMode.ready &&
          !footerNotifier._indicator.springRebound &&
          value <
              position.maxScrollExtent + footerNotifier.actualTriggerOffset) {
        _updateIndicatorOffset(
            position,
            position.maxScrollExtent + footerNotifier.actualTriggerOffset,
            value);
        return (value - footerNotifier.actualTriggerOffset) -
            position.maxScrollExtent;
      }
      // 不能越过二楼高度。
      if (footerNotifier.hasSecondary) {
        if (position.maxScrollExtent + footerNotifier.secondaryDimension <=
                position.pixels &&
            position.pixels < value) {
          // 底部继续外拉。
          bounds = value - position.pixels;
        } else if (position.pixels - footerNotifier.secondaryDimension <
                position.maxScrollExtent &&
            position.maxScrollExtent <
                value - footerNotifier.secondaryDimension) {
          // 碰到底部边缘，钳住列表。
          _updateIndicatorOffset(
              position,
              position.maxScrollExtent + footerNotifier.secondaryDimension,
              value);
          return value -
              footerNotifier.secondaryDimension -
              position.maxScrollExtent;
        }
      }
    }
    // 未命中钳制时，把目标像素同步给两个 notifier。
    _updateIndicatorOffset(position, value, value);
    return bounds;
  }

  /// 把滚动位置同步到 Header / Footer offset。
  void _updateIndicatorOffset(
      ScrollMetrics position, double offset, double value) {
    // NestedScrollView 外层在未锁定时忽略正向回推，避免把 Header 提前收掉。
    if (headerNotifier.isNested &&
        position.isNestedOuter &&
        headerNotifier._offset > 0 &&
        value > position.minScrollExtent &&
        !headerNotifier.modeLocked) {
      return;
    }
    final hClamping = headerNotifier.clamping && headerNotifier.offset > 0;
    final fClamping = footerNotifier.clamping && footerNotifier.offset > 0;
    headerNotifier._updateOffset(position, fClamping ? 0 : offset, false);
    footerNotifier._updateOffset(position, hClamping ? 0 : offset, false);
  }

  /// 松手后的惯性 / 回弹。leading / trailing 会加上 Header / Footer 的 [overExtent]。
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    Tolerance tolerance = toleranceFor(position);
    // 用户松手，进入惯性 / 回弹。
    final oldUserOffset = userOffsetNotifier.value;
    userOffsetNotifier.value = false;
    final oldMaxScrollExtent =
        headerNotifier._lastMaxScrollExtent ?? position.maxScrollExtent;
    headerNotifier._updateBySimulation(position, velocity);
    footerNotifier._updateBySimulation(position, velocity);
    final hState = _BallisticSimulationCreationState(
      mode: headerNotifier._mode,
      offset: headerNotifier._offset,
      actualTriggerOffset: headerNotifier.actualTriggerOffset,
    );
    final fState = _BallisticSimulationCreationState(
      mode: footerNotifier._mode,
      offset: footerNotifier._offset,
      actualTriggerOffset: footerNotifier.actualTriggerOffset,
    );
    Simulation? simulation;
    // bouncing 二楼：松手后用最低速度滚到二楼高度。
    bool hSecondary = !headerNotifier.clamping &&
        (headerNotifier._mode == FastRefreshMode.secondaryReady ||
            headerNotifier._mode == FastRefreshMode.secondaryOpen);
    bool fSecondary = !footerNotifier.clamping &&
        (footerNotifier._mode == FastRefreshMode.secondaryReady ||
            footerNotifier._mode == FastRefreshMode.secondaryOpen);
    bool secondary = hSecondary || fSecondary;
    if (velocity.abs() >= tolerance.velocity ||
        ((FastRefreshMode.inactive != headerNotifier.mode ||
                FastRefreshMode.inactive != footerNotifier.mode) &&
            oldMaxScrollExtent != position.maxScrollExtent &&
            position.maxScrollExtent != 0) ||
        (position.outOfRange || (secondary && oldUserOffset)) &&
            (oldUserOffset ||
                _headerSimulationCreationState.value.needCreation(hState) ||
                _footerSimulationCreationState.value.needCreation(fState))) {
      double mVelocity = velocity;
      // 已顶到越界上限时清掉惯性速度，避免继续往外冲。
      if (mVelocity < 0 &&
          headerNotifier.actualMaxOverOffset != double.infinity &&
          headerNotifier._offset != 0 &&
          headerNotifier._offset >= headerNotifier.actualMaxOverOffset) {
        mVelocity = 0;
      } else if (mVelocity > 0 &&
          footerNotifier.actualMaxOverOffset != double.infinity &&
          footerNotifier._offset != 0 &&
          footerNotifier._offset >= footerNotifier.actualMaxOverOffset) {
        mVelocity = 0;
      }
      // 打开二楼时保证最低速度。
      if (secondary) {
        if (hSecondary) {
          if (headerNotifier.offset == headerNotifier.secondaryDimension) {
            mVelocity = 0;
          } else if (mVelocity > -headerNotifier.secondaryVelocity) {
            mVelocity = -headerNotifier.secondaryVelocity;
          }
        } else if (fSecondary) {
          if (footerNotifier.offset == footerNotifier.secondaryDimension) {
            mVelocity = 0;
          } else if (mVelocity < footerNotifier.secondaryVelocity) {
            mVelocity = footerNotifier.secondaryVelocity;
          }
        }
      }
      simulation = BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: mVelocity,
        leadingExtent: position.minScrollExtent - headerNotifier.overExtent,
        trailingExtent: position.maxScrollExtent + footerNotifier.overExtent,
        tolerance: tolerance,
      );
    }
    _headerSimulationCreationState.value = hState;
    _footerSimulationCreationState.value = fState;
    return simulation;
  }
}

/// 创建惯性模拟时的指示器快照，用来判断是否需要重建模拟。
class _BallisticSimulationCreationState {
  /// 当时的指示器模式。
  final FastRefreshMode mode;

  /// 当时的越界偏移。
  final double offset;

  /// 当时的实际触发距离。
  final double actualTriggerOffset;

  /// 创建惯性模拟快照。
  const _BallisticSimulationCreationState({
    required this.mode,
    required this.offset,
    required this.actualTriggerOffset,
  });

  /// 模式 / 偏移变化，或 ready 已到达触发位时，需要重建惯性模拟。
  bool needCreation(_BallisticSimulationCreationState newState) {
    return mode != newState.mode ||
        offset != newState.offset ||
        (newState.mode == FastRefreshMode.ready &&
            newState.offset >= actualTriggerOffset);
  }
}

/// [ScrollMetrics] 扩展：识别 NestedScrollView 内外层。
extension _ScrollMetricsExtension on ScrollMetrics {
  /// NestedScrollView 外层。
  bool get isNestedOuter =>
      this is ScrollPosition && (this as ScrollPosition).debugLabel == 'outer';

  /// NestedScrollView 内层。
  bool get isNestedInner =>
      this is ScrollPosition && (this as ScrollPosition).debugLabel == 'inner';
}
