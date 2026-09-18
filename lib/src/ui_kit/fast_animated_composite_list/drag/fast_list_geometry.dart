import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Visible-item geometry used while dragging.
/// 拖拽时用的可见项几何。
///
/// Only mounted item states register here. Off-screen rows are estimated from
/// the dragged extent when needed.
/// 只有已挂载的 item 会注册。屏幕外行在需要时用拖拽项尺寸估算。
class FastListGeometry {
  final Map<Object, FastListSlotHandle> _slots = <Object, FastListSlotHandle>{};

  /// Registers [handle] for [id].
  /// 为 [id] 注册 [handle]。
  void register(Object id, FastListSlotHandle handle) {
    _slots[id] = handle;
  }

  /// Drops [id] when the item unmounts.
  /// item 卸载时去掉 [id]。
  void unregister(Object id, FastListSlotHandle handle) {
    if (_slots[id] == handle) {
      _slots.remove(id);
    }
  }

  /// Global origin of [id], or null if not laid out.
  /// [id] 的全局原点；未布局则为 null。
  Offset? globalOrigin(Object id) {
    final RenderBox? box = _box(id);
    if (box == null) {
      return null;
    }
    return box.localToGlobal(Offset.zero);
  }

  /// Size of [id], or null.
  /// [id] 的尺寸。
  Size? sizeOf(Object id) => _box(id)?.size;

  /// Whether any of [ids] currently has a laid-out box.
  /// [ids] 里是否已有完成布局的 box。
  bool hasAnyBox(List<Object> ids) {
    for (final Object id in ids) {
      if (_box(id) != null) {
        return true;
      }
    }
    return false;
  }

  /// Hover index for [global] among [ids].
  /// 在 [ids] 里用 [global] 找悬停下标。
  int hoverAt(Offset global, List<Object> ids, int fallback) {
    int? containing;
    int? nearest;
    double best = double.infinity;
    for (int i = 0; i < ids.length; i++) {
      final Offset? origin = globalOrigin(ids[i]);
      final Size? size = sizeOf(ids[i]);
      if (origin == null || size == null) {
        continue;
      }
      final Rect rect = origin & size;
      if (rect.contains(global)) {
        containing = i;
        break;
      }
      final double d = (rect.center - global).distanceSquared;
      if (d < best) {
        best = d;
        nearest = i;
      }
    }
    return containing ?? nearest ?? fallback;
  }

  /// Pixel translation so [index] visually occupies [target]’s slot.
  /// 让 [index] 视觉上落到 [target] 槽位的像素位移。
  Offset offsetBetween({
    required List<Object> ids,
    required int index,
    required int target,
  }) {
    if (index == target ||
        index < 0 ||
        target < 0 ||
        index >= ids.length ||
        target >= ids.length) {
      return Offset.zero;
    }
    final Offset? from = globalOrigin(ids[index]);
    final Offset? to = globalOrigin(ids[target]);
    if (from == null || to == null) {
      return Offset.zero;
    }
    return to - from;
  }

  RenderBox? _box(Object id) {
    final FastListSlotHandle? handle = _slots[id];
    if (handle == null) {
      return null;
    }
    final RenderBox? box = handle.renderBox;
    if (box == null || !box.hasSize || !box.attached) {
      return null;
    }
    return box;
  }
}

/// An item that can report its [RenderBox].
/// 能报告自己 [RenderBox] 的 item。
abstract class FastListSlotHandle {
  /// Current render box, if laid out.
  /// 当前 render box（已布局时）。
  RenderBox? get renderBox;
}
