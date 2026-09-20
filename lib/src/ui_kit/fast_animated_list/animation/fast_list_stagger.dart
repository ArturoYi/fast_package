import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How first-frame children are delayed.
/// 首屏子项如何错开。
enum FastListStaggerKind {
  /// No stagger delay.
  /// 不错开。
  none,

  /// All children start together.
  /// 所有子项同时开始。
  synchronized,

  /// Single-axis delay: `position * delay`.
  /// 单轴：`position * delay`。
  list,

  /// Dual-axis delay: `(row + col) * delay`.
  /// 双轴：`(row + col) * delay`。
  grid,
}

/// Stagger configuration for first-frame entrance and batch inserts.
/// 首屏入场与批量插入的错开配置。
///
/// 列表：`position * delay`；网格：
/// `(position ~/ columnCount + position % columnCount) * delay`。
@immutable
class FastListStagger {
  /// No stagger. Children appear with their mutation animation only.
  /// 不错开，只保留增删动画。
  const FastListStagger.none()
      : kind = FastListStaggerKind.none,
        duration = Duration.zero,
        delay = Duration.zero,
        columnCount = 1,
        maxItems = 0;

  /// All first-frame children share the same start.
  /// 首屏子项同时开播。
  const FastListStagger.synchronized({
    this.duration = const Duration(milliseconds: 225),
  })  : kind = FastListStaggerKind.synchronized,
        delay = Duration.zero,
        columnCount = 1,
        maxItems = 0;

  /// Single-axis stagger (ListView / Column / Row).
  /// 单轴错开（列表 / 列 / 行）。
  const FastListStagger.list({
    this.duration = const Duration(milliseconds: 225),
    this.delay,
    this.maxItems = 16,
  })  : kind = FastListStaggerKind.list,
        columnCount = 1,
        assert(maxItems >= 0, 'maxItems must be >= 0');

  /// Dual-axis stagger (GridView).
  /// 双轴错开（网格）。
  const FastListStagger.grid({
    required this.columnCount,
    this.duration = const Duration(milliseconds: 225),
    this.delay,
    this.maxItems = 16,
  })  : kind = FastListStaggerKind.grid,
        assert(columnCount > 0, 'columnCount must be > 0'),
        assert(maxItems >= 0, 'maxItems must be >= 0');

  /// Stagger kind.
  /// 错开类型。
  final FastListStaggerKind kind;

  /// Per-item entrance duration.
  /// 单项入场时长。
  final Duration duration;

  /// Gap between two children. Defaults to [duration] / 6 when null.
  /// 两项之间的间隔；`null` 时为 [duration] / 6。
  final Duration? delay;

  /// Grid column count. Always 1 for list / synchronized / none.
  /// 网格列数。列表 / 同步 / none 时为 1。
  final int columnCount;

  /// Positions above this share the last delay (caps controller length).
  /// 超过该 position 的项共用最后一档 delay，避免 AnimationController 过长。
  final int maxItems;

  /// Whether a shared AnimationController should run.
  /// 是否需要共用的 AnimationController。
  bool get isEnabled => kind != FastListStaggerKind.none;

  /// Resolved delay between children.
  /// 子项之间的实际 delay。
  Duration get resolvedDelay {
    if (kind == FastListStaggerKind.none ||
        kind == FastListStaggerKind.synchronized) {
      return Duration.zero;
    }
    return delay ??
        Duration(milliseconds: math.max(1, duration.inMilliseconds ~/ 6));
  }

  /// Start delay for [position].
  /// [position] 的起始 delay。
  Duration delayFor(int position) {
    switch (kind) {
      case FastListStaggerKind.none:
      case FastListStaggerKind.synchronized:
        return Duration.zero;
      case FastListStaggerKind.list:
        return resolvedDelay * _cappedPosition(position);
      case FastListStaggerKind.grid:
        final int p = _cappedPosition(position);
        return resolvedDelay * (p ~/ columnCount + p % columnCount);
    }
  }

  /// Total duration covering the last capped child.
  /// 覆盖到最后一档子项的总时长。
  Duration get totalDuration {
    if (!isEnabled) {
      return Duration.zero;
    }
    if (kind == FastListStaggerKind.synchronized) {
      return duration;
    }
    final int last = maxItems == 0 ? 0 : maxItems - 1;
    return delayFor(last) + duration;
  }

  /// Interval start / end in `0..1` for a shared parent animation.
  /// 共享父动画上该 position 的 `0..1` 区间。
  (double, double) intervalFor(int position) {
    final int totalMs = math.max(1, totalDuration.inMilliseconds);
    final double start = delayFor(position).inMilliseconds / totalMs;
    final double end = math.min(
      1,
      (delayFor(position) + duration).inMilliseconds / totalMs,
    );
    if (end <= start) {
      return (math.min(start, 0.999), 1);
    }
    return (start, end);
  }

  /// AnimatedList duration covering this insert's delay plus [insertDuration].
  /// 覆盖本条插入 delay 与 [insertDuration] 的 AnimatedList 时长。
  Duration mutationDurationFor(int ordinal, Duration insertDuration) {
    return insertDuration + delayFor(ordinal);
  }

  /// Interval begin in `0..1` so the [ordinal]-th insert in a batch waits first.
  /// 同一批发插入中第 [ordinal] 条的 Interval 起点，先等 delay 再播。
  double mutationIntervalBegin(int ordinal, Duration insertDuration) {
    final Duration delay = delayFor(ordinal);
    final int totalMs = (insertDuration + delay).inMilliseconds;
    if (delay <= Duration.zero || totalMs <= 0) {
      return 0;
    }
    return math.min(0.999, delay.inMilliseconds / totalMs);
  }

  int _cappedPosition(int position) {
    if (maxItems <= 0) {
      return 0;
    }
    return math.min(position, maxItems - 1);
  }

  @override
  bool operator ==(Object other) {
    return other is FastListStagger &&
        other.kind == kind &&
        other.duration == duration &&
        other.delay == delay &&
        other.columnCount == columnCount &&
        other.maxItems == maxItems;
  }

  @override
  int get hashCode => Object.hash(kind, duration, delay, columnCount, maxItems);
}

/// Inherited stagger clock. One AnimationController for the whole subtree.
/// 错开入场的 Inherited 时钟。整棵子树共用一个 AnimationController。
class FastStaggerScope extends InheritedWidget {
  /// Creates a scope.
  /// 创建作用域。
  const FastStaggerScope({
    super.key,
    required this.animation,
    required this.stagger,
    required this.limitNewItems,
    required super.child,
  });

  /// Shared 0→1 animation.
  /// 共享的 0→1 动画。
  final Animation<double> animation;

  /// Stagger settings.
  /// 错开配置。
  final FastListStagger stagger;

  /// When true, newly built slots skip entrance (scroll-in limiter).
  /// 为 true 时新构建的 slot 不再入场（滚入限制）。
  final bool limitNewItems;

  /// Nearest scope, or null.
  /// 最近的作用域；没有则为 null。
  static FastStaggerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FastStaggerScope>();
  }

  @override
  bool updateShouldNotify(FastStaggerScope oldWidget) {
    return animation != oldWidget.animation ||
        stagger != oldWidget.stagger ||
        limitNewItems != oldWidget.limitNewItems;
  }
}
