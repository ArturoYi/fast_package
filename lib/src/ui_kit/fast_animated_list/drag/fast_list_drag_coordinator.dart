import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'fast_list_geometry.dart';

/// How a reorder drag starts.
/// 排序拖拽如何开始。
enum FastListDragTrigger {
  /// Long-press the row.
  /// 长按整行。
  longPress,

  /// Drag from [FastListDragHandle] only.
  /// 只能从 [FastListDragHandle] 拖。
  handle,
}

/// Drag session shared by items. Notifies only when indices change.
/// item 共享的拖拽会话。只在下标变化时通知。
class FastListDragCoordinator extends ChangeNotifier {
  int? _dragIndex;
  int? _hoverIndex;
  Object? _dragId;
  Size _draggedSize = Size.zero;

  /// Index of the lifted item.
  /// 被提起项的下标。
  int? get dragIndex => _dragIndex;

  /// Slot the pointer is hovering.
  /// 指针正悬停的槽位。
  int? get hoverIndex => _hoverIndex;

  /// Identity of the lifted item.
  /// 被提起项的 identity。
  Object? get dragId => _dragId;

  /// Size of the lifted item (keeps the gap).
  /// 被提起项的尺寸（用来留出空隙）。
  Size get draggedSize => _draggedSize;

  /// Whether a drag is active.
  /// 是否正在拖。
  bool get isDragging => _dragIndex != null;

  /// Starts a drag. Notifies listeners once.
  /// 开始拖拽。通知一次。
  void start({
    required int index,
    required Object id,
    required Size size,
  }) {
    _dragIndex = index;
    _hoverIndex = index;
    _dragId = id;
    _draggedSize = size;
    notifyListeners();
  }

  /// Updates [hoverIndex] if it changed.
  /// [hoverIndex] 变了才更新。
  bool updateHover(int next) {
    if (!isDragging || next == _hoverIndex) {
      return false;
    }
    _hoverIndex = next;
    notifyListeners();
    return true;
  }

  /// Clears the session.
  /// 结束会话。
  void end() {
    if (!isDragging) {
      return;
    }
    _dragIndex = null;
    _hoverIndex = null;
    _dragId = null;
    _draggedSize = Size.zero;
    notifyListeners();
  }

  /// Translation for a settled item at [index] while dragging.
  /// 拖拽时，已就位的 [index] 应平移多少。
  Offset shiftFor({
    required int index,
    required List<Object> ids,
    required FastListGeometry geometry,
  }) {
    final int? drag = _dragIndex;
    final int? hover = _hoverIndex;
    if (drag == null || hover == null || index == drag) {
      return Offset.zero;
    }
    final int target;
    if (drag < hover && index > drag && index <= hover) {
      target = index - 1;
    } else if (drag > hover && index >= hover && index < drag) {
      target = index + 1;
    } else {
      return Offset.zero;
    }
    return geometry.offsetBetween(ids: ids, index: index, target: target);
  }
}

/// Per-item drag callbacks for [FastListDragHandle].
/// 供 [FastListDragHandle] 使用的逐项拖拽回调。
class FastListItemDragScope extends InheritedWidget {
  /// Creates a scope.
  /// 创建作用域。
  const FastListItemDragScope({
    super.key,
    required this.index,
    required this.enabled,
    required this.trigger,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required super.child,
  });

  /// Item index.
  /// 项下标。
  final int index;

  /// Whether reorder is currently allowed.
  /// 当前是否允许排序。
  final bool enabled;

  /// How a drag may start.
  /// 拖拽如何开始。
  final FastListDragTrigger trigger;

  /// Starts a drag at [global].
  /// 在 [global] 开始拖。
  final void Function(int index, Offset global) onDragStart;

  /// Pointer moved to [global].
  /// 指针移到 [global]。
  final ValueChanged<Offset> onDragUpdate;

  /// Ends or cancels the drag.
  /// 结束或取消拖拽。
  final ValueChanged<bool> onDragEnd;

  /// Nearest item scope, or null.
  /// 最近的 item 作用域。
  static FastListItemDragScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FastListItemDragScope>();
  }

  @override
  bool updateShouldNotify(FastListItemDragScope oldWidget) {
    return index != oldWidget.index ||
        enabled != oldWidget.enabled ||
        trigger != oldWidget.trigger;
  }
}

/// Drag handle for [FastListDragTrigger.handle].
/// [FastListDragTrigger.handle] 使用的拖拽手柄。
///
/// Accepts the arena on pointer down so the parent [Scrollable] cannot steal a
/// vertical drag. The overlay proxy is created after slop so a tap is a no-op.
/// 按下即赢手势竞技场，避免父级 [Scrollable] 抢走纵向拖。过 slop 才出代理，点按不会排序。
class FastListDragHandle extends StatelessWidget {
  /// Creates a handle.
  /// 创建手柄。
  const FastListDragHandle({
    super.key,
    this.semanticLabel = 'Reorder',
    required this.child,
  });

  /// Accessibility label.
  /// 无障碍标签。
  final String semanticLabel;

  /// Typically an icon.
  /// 通常是图标。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final FastListItemDragScope? scope = FastListItemDragScope.maybeOf(context);
    final bool enabled = scope != null &&
        scope.enabled &&
        scope.trigger == FastListDragTrigger.handle;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: enabled
            ? <Type, GestureRecognizerFactory>{
                _FastListHandleDragRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        _FastListHandleDragRecognizer>(
                  () => _FastListHandleDragRecognizer(debugOwner: this),
                  (_FastListHandleDragRecognizer instance) {
                    instance
                      ..onStart = (Offset offset) {
                        scope.onDragStart(scope.index, offset);
                      }
                      ..onUpdate = scope.onDragUpdate
                      ..onEnd = () {
                        scope.onDragEnd(false);
                      }
                      ..onCancel = () {
                        scope.onDragEnd(true);
                      };
                  },
                ),
              }
            : const <Type, GestureRecognizerFactory>{},
        child: child,
      ),
    );
  }
}

/// Immediate-accept drag used only by [FastListDragHandle].
/// 仅给 [FastListDragHandle] 用的「立刻接受」拖拽识别。
class _FastListHandleDragRecognizer extends OneSequenceGestureRecognizer {
  _FastListHandleDragRecognizer({super.debugOwner});

  /// Called once after the pointer moves past slop.
  /// 指针走过 slop 后调用一次。
  ValueChanged<Offset>? onStart;

  /// Pointer moved.
  /// 指针移动。
  ValueChanged<Offset>? onUpdate;

  /// Pointer up after a live drag.
  /// 已开始的拖拽松手。
  VoidCallback? onEnd;

  /// Arena lost or pointer cancelled.
  /// 竞技场失败或指针取消。
  VoidCallback? onCancel;

  Offset? _origin;
  PointerDeviceKind _kind = PointerDeviceKind.touch;
  bool _dragging = false;

  double get _slop => computeHitSlop(_kind, gestureSettings);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _kind = event.kind;
    _origin = event.position;
    _dragging = false;
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (!_dragging) {
        final Offset origin = _origin ?? event.position;
        if ((event.position - origin).distance > _slop) {
          _dragging = true;
          onStart?.call(origin);
          onUpdate?.call(event.position);
        }
      } else {
        onUpdate?.call(event.position);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _finish(cancelled: event is PointerCancelEvent);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {
    _finish(cancelled: true);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void dispose() {
    _finish(cancelled: true);
    super.dispose();
  }

  @override
  String get debugDescription => 'fast list drag handle';

  void _finish({required bool cancelled}) {
    if (!_dragging) {
      _origin = null;
      return;
    }
    _dragging = false;
    _origin = null;
    if (cancelled) {
      onCancel?.call();
    } else {
      onEnd?.call();
    }
  }
}
