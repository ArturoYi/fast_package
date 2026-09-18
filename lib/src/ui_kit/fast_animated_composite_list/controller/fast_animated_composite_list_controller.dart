import 'package:flutter/foundation.dart';

/// Observes mutation / drag occupancy. Does not own [items].
/// 观察增删 / 拖拽占用。不持有 items。
///
/// Pass an instance into the list; the caller [dispose]s it. If omitted, the
/// State creates and disposes its own controller.
/// 传入实例时由调用方 [dispose]；未传入时由 State 自建自毁。
class FastAnimatedCompositeListController extends ChangeNotifier {
  /// Creates a controller.
  /// 创建控制器。
  FastAnimatedCompositeListController();

  bool _animating = false;
  bool _dragging = false;

  /// True while an insert / remove animation is in flight.
  /// 插入 / 删除动画进行中。
  bool get isAnimating => _animating;

  /// True while a drag reorder is active.
  /// 正在拖拽排序。
  bool get isDragging => _dragging;

  /// Called by the list host. Not a public mutation API.
  /// 列表宿主调用。不是对外改数据的 API。
  void setAnimating(bool value) {
    if (_animating == value) {
      return;
    }
    _animating = value;
    notifyListeners();
  }

  /// Called by the list host. Not a public mutation API.
  /// 列表宿主调用。不是对外改数据的 API。
  void setDragging(bool value) {
    if (_dragging == value) {
      return;
    }
    _dragging = value;
    notifyListeners();
  }
}
