import 'package:flutter/foundation.dart';

/// One sequential operation that transforms an id list into another.
/// 把旧 id 列表变成新 id 列表的一步。
@immutable
sealed class FastListOp {
  const FastListOp();
}

/// Remove the item currently at [index].
/// 删除当前 [index] 上的项。
@immutable
class FastListRemoveOp extends FastListOp {
  /// Creates a remove op.
  /// 创建删除操作。
  const FastListRemoveOp(this.index);

  /// Index in the working list before this op runs.
  /// 执行前工作列表中的下标。
  final int index;

  @override
  bool operator ==(Object other) =>
      other is FastListRemoveOp && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// Insert [id] at [index].
/// 在 [index] 插入 [id]。
@immutable
class FastListInsertOp extends FastListOp {
  /// Creates an insert op.
  /// 创建插入操作。
  const FastListInsertOp(this.index, this.id);

  /// Index in the working list before this op runs.
  /// 执行前工作列表中的下标。
  final int index;

  /// Identity of the inserted item.
  /// 插入项的 identity。
  final Object id;

  @override
  bool operator ==(Object other) =>
      other is FastListInsertOp && other.index == index && other.id == id;

  @override
  int get hashCode => Object.hash(index, id);
}

/// Move the item at [from] to [to] in the working list.
/// 把工作列表里 [from] 的项移到 [to]。
@immutable
class FastListMoveOp extends FastListOp {
  /// Creates a move op.
  /// 创建移动操作。
  const FastListMoveOp(this.from, this.to);

  /// Source index.
  /// 源下标。
  final int from;

  /// Destination index after removal.
  /// 删除源项之后的目标下标。
  final int to;

  @override
  bool operator ==(Object other) =>
      other is FastListMoveOp && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Result of diffing two identity lists.
/// 两次 identity 列表的差异。
@immutable
class FastListDiff {
  /// Creates a diff.
  /// 创建 diff。
  const FastListDiff({
    required this.ops,
    this.reset = false,
  });

  /// Empty / identical lists.
  /// 空差异。
  static const FastListDiff empty = FastListDiff(
    ops: <FastListOp>[],
    reset: false,
  );

  /// Too many edits; snap instead of animating each op.
  /// 改动过多，应对齐而不是逐条动画。
  static const FastListDiff snap = FastListDiff(
    ops: <FastListOp>[],
    reset: true,
  );

  /// Sequential ops. Empty when [reset] is true.
  /// 顺序操作。[reset] 为 true 时为空。
  final List<FastListOp> ops;

  /// Whether the host should rebuild the sliver without per-item animation.
  /// 宿主是否应整表对齐、不做逐条动画。
  final bool reset;

  /// Whether anything changed.
  /// 是否有变化。
  bool get isEmpty => !reset && ops.isEmpty;

  /// Contiguous inserts after existing items (load-more / append).
  /// 现有条目之后的连续插入（上拉加载 / 追加）。
  ///
  /// Head inserts stay `false` so first-page and top-insert animations run.
  /// 头部插入仍为 `false`，首屏和顶部插入继续走动画。
  bool get isTailAppend {
    if (reset || ops.isEmpty) {
      return false;
    }
    int? previousIndex;
    for (final FastListOp op in ops) {
      if (op is! FastListInsertOp) {
        return false;
      }
      if (previousIndex != null && op.index != previousIndex + 1) {
        return false;
      }
      previousIndex = op.index;
    }
    return (ops.first as FastListInsertOp).index > 0;
  }
}

/// Identity-based list diff with cheap paths for append / single edit / move.
/// 基于 identity 的列表 diff，对追加、单次编辑、单元素移动走快路径。
final class FastListDiffer {
  /// Creates a differ.
  /// 创建 differ。
  const FastListDiffer({this.animationBudget = 24});

  /// If insert+remove (or a messy permutation) exceeds this, [FastListDiff.snap].
  /// 插入+删除（或复杂重排）超过该值时整表对齐。
  final int animationBudget;

  /// Diff [oldIds] into [newIds]. Both must have unique ids.
  /// 计算从 [oldIds] 到 [newIds] 的差异。两侧 id 必须唯一。
  FastListDiff compute(List<Object> oldIds, List<Object> newIds) {
    debugAssertUniqueItemIds(oldIds);
    debugAssertUniqueItemIds(newIds);

    if (listEquals(oldIds, newIds)) {
      return FastListDiff.empty;
    }

    if (oldIds.isEmpty) {
      if (newIds.length > animationBudget) {
        return FastListDiff.snap;
      }
      return FastListDiff(
        ops: <FastListOp>[
          for (int i = 0; i < newIds.length; i++)
            FastListInsertOp(i, newIds[i]),
        ],
      );
    }

    if (newIds.isEmpty) {
      if (oldIds.length > animationBudget) {
        return FastListDiff.snap;
      }
      return FastListDiff(
        ops: <FastListOp>[
          for (int i = oldIds.length - 1; i >= 0; i--) FastListRemoveOp(i),
        ],
      );
    }

    final Set<Object> oldSet = oldIds.toSet();
    final Set<Object> newSet = newIds.toSet();
    int removed = 0;
    for (final Object id in oldIds) {
      if (!newSet.contains(id)) {
        removed++;
      }
    }
    int inserted = 0;
    for (final Object id in newIds) {
      if (!oldSet.contains(id)) {
        inserted++;
      }
    }

    if (removed + inserted > animationBudget) {
      return FastListDiff.snap;
    }

    if (removed == 0 && inserted == 0) {
      final FastListMoveOp? move = detectSingleMove(oldIds, newIds);
      if (move != null) {
        return FastListDiff(ops: <FastListOp>[move]);
      }
      if (oldIds.length > animationBudget) {
        return FastListDiff.snap;
      }
    }

    final List<Object> working = List<Object>.of(oldIds);
    final List<FastListOp> ops = <FastListOp>[];

    for (int i = working.length - 1; i >= 0; i--) {
      if (!newSet.contains(working[i])) {
        ops.add(FastListRemoveOp(i));
        working.removeAt(i);
      }
    }

    if (inserted == 0 && working.length == newIds.length) {
      final FastListMoveOp? move = detectSingleMove(working, newIds);
      if (move != null) {
        ops.add(move);
        return FastListDiff(ops: ops);
      }
    }

    for (int i = 0; i < newIds.length; i++) {
      final Object id = newIds[i];
      if (i < working.length && working[i] == id) {
        continue;
      }
      final int existing = working.indexOf(id);
      if (existing == -1) {
        ops.add(FastListInsertOp(i, id));
        working.insert(i, id);
      } else {
        ops.add(FastListMoveOp(existing, i));
        working
          ..removeAt(existing)
          ..insert(i, id);
      }
    }

    if (ops.length > animationBudget) {
      return FastListDiff.snap;
    }
    return FastListDiff(ops: ops);
  }

  /// Detects a single relocation that turns [oldIds] into [newIds].
  /// 检测把 [oldIds] 变成 [newIds] 的单元素移动。
  static FastListMoveOp? detectSingleMove(
    List<Object> oldIds,
    List<Object> newIds,
  ) {
    if (oldIds.length != newIds.length || oldIds.length < 2) {
      return null;
    }
    int first = -1;
    int last = -1;
    for (int i = 0; i < oldIds.length; i++) {
      if (oldIds[i] != newIds[i]) {
        if (first < 0) {
          first = i;
        }
        last = i;
      }
    }
    if (first < 0 || first == last) {
      return null;
    }

    if (oldIds[first] == newIds[last] &&
        _regionEquals(oldIds, first + 1, last + 1, newIds, first, last)) {
      return FastListMoveOp(first, last);
    }
    if (oldIds[last] == newIds[first] &&
        _regionEquals(oldIds, first, last, newIds, first + 1, last + 1)) {
      return FastListMoveOp(last, first);
    }
    return null;
  }
}

/// Asserts [ids] are unique in debug builds.
/// debug 下断言 [ids] 不重复。
void debugAssertUniqueItemIds(List<Object> ids) {
  assert(() {
    final Set<Object> seen = <Object>{};
    for (final Object id in ids) {
      assert(seen.add(id), 'Duplicate FastAnimatedList itemId: $id');
    }
    return true;
  }());
}

bool _regionEquals(
  List<Object> a,
  int aStart,
  int aEnd,
  List<Object> b,
  int bStart,
  int bEnd,
) {
  if (aEnd - aStart != bEnd - bStart) {
    return false;
  }
  for (int i = 0; i < aEnd - aStart; i++) {
    if (a[aStart + i] != b[bStart + i]) {
      return false;
    }
  }
  return true;
}
