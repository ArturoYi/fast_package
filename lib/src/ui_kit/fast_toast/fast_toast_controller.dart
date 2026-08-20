import 'package:flutter/material.dart';

import 'fast_toast_queue.dart';
import 'widgets/fast_toast_view.dart';

/// Singleton scheduler: FIFO queue and a single overlay slot.
/// 单例调度：FIFO 队列 + 单槽 Overlay。
///
/// Not part of the public API.
/// 不属于公开 API。
final class FastToastController {
  FastToastController._();

  /// Shared instance used by [showToast] / [FastToastOverlay].
  /// [showToast] / [FastToastOverlay] 使用的共享实例。
  static final FastToastController instance = FastToastController._();

  final FastToastQueue _queue = FastToastQueue();

  OverlayState? _overlayState;
  OverlayEntry? _entry;
  VoidCallback? _dismissCurrent;
  FastToastRequest? _current;
  bool _isShowing = false;

  /// Whether a toast is currently on screen.
  /// 当前是否正在展示 Toast。
  bool get isShowing => _isShowing;

  /// Pending queue length, excluding the visible toast.
  /// 待展示队列长度（不含当前条）。
  int get pendingCount => _queue.length;

  /// Registers the root [OverlayState] and shows the next pending toast.
  /// 注册根 [OverlayState]，并尝试展示下一条 pending。
  void attach(OverlayState overlayState) {
    _overlayState = overlayState;
    _tryShowNext();
  }

  /// Unregisters [overlayState] if it is the active host.
  /// 若 [overlayState] 是当前宿主则注销。
  ///
  /// Omitting [overlayState] always detaches (used by tests).
  /// 省略 [overlayState] 时一律注销（测试用）。
  void detach([OverlayState? overlayState]) {
    if (overlayState != null &&
        _overlayState != null &&
        !identical(overlayState, _overlayState)) {
      return;
    }
    _removeEntry();
    _overlayState = null;
    _current = null;
    _isShowing = false;
  }

  /// Enqueues [request] and shows it if the slot is free and attached.
  /// 将 [request] 入队；槽空且已挂载时立即展示。
  void enqueue(FastToastRequest request) {
    _queue.enqueue(request);
    _tryShowNext();
  }

  /// Plays exit animation for the current toast if one is showing.
  /// 若有当前条，则播放退场动画。空闲时为空操作。
  void dismiss() {
    if (!_isShowing || _current == null) {
      return;
    }
    _dismissCurrent?.call();
  }

  /// Clears the queue and removes the current entry immediately.
  /// 清空队列并立即移除当前条目（无退场）。
  void dismissAll() {
    _queue.clear();
    _removeEntry();
    _current = null;
    _isShowing = false;
  }

  void _tryShowNext() {
    if (_isShowing || _overlayState == null || _queue.isEmpty) {
      return;
    }

    final FastToastRequest? next = _queue.dequeue();
    if (next == null) {
      return;
    }

    _current = next;
    _isShowing = true;
    _insert(next);
  }

  void _insert(FastToastRequest request) {
    final OverlayState? overlayState = _overlayState;
    if (overlayState == null) {
      _current = null;
      _isShowing = false;
      return;
    }

    _removeEntry();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return FastToastView(
          request: request,
          onRegisterDismiss: (VoidCallback trigger) {
            _dismissCurrent = trigger;
          },
          onDismissed: () => _onEntryDismissed(entry),
        );
      },
    );

    _entry = entry;
    overlayState.insert(entry);
  }

  void _onEntryDismissed(OverlayEntry entry) {
    if (_entry != entry) {
      return;
    }
    _removeEntry();
    _current = null;
    _isShowing = false;
    _tryShowNext();
  }

  void _removeEntry() {
    final OverlayEntry? entry = _entry;
    if (entry == null) {
      _dismissCurrent = null;
      return;
    }
    entry.remove();
    entry.dispose();
    _entry = null;
    _dismissCurrent = null;
  }

  /// Test-only reset of singleton state.
  /// 仅测试用：重置单例状态。
  @visibleForTesting
  void resetForTest() {
    _queue.clear();
    _removeEntry();
    _overlayState = null;
    _current = null;
    _isShowing = false;
  }
}
