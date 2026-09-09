import 'package:flutter/material.dart';

import 'fast_loading_request.dart';
import 'widgets/fast_loading_view.dart';

/// Singleton host: one centered overlay slot, no queue.
/// 单例宿主：仅一个居中 Overlay 槽，不排队。
///
/// A later [show] replaces the visible loading immediately.
/// 再次 [show] 会立即替换当前 Loading。
///
/// Not part of the public API.
/// 不属于公开 API。
final class FastLoadingController with WidgetsBindingObserver {
  FastLoadingController._();

  /// Shared instance used by [showLoading] / [FastLoadingOverlay].
  /// [showLoading] / [FastLoadingOverlay] 使用的共享实例。
  static final FastLoadingController instance = FastLoadingController._();

  OverlayState? _overlayState;
  OverlayEntry? _entry;
  VoidCallback? _dismissCurrent;
  FastLoadingRequest? _current;
  FastLoadingRequest? _pending;
  bool _isShowing = false;

  GlobalKey<NavigatorState>? _navigatorKey;
  ModalRoute<dynamic>? _lockedRoute;
  bool _observingBinding = false;
  final _LoadingPopLock _popLock = _LoadingPopLock();

  /// Whether a loading overlay is currently on screen.
  /// 当前是否正在展示 Loading。
  bool get isShowing => _isShowing;

  /// Registers the root [OverlayState] and shows a pending request if any.
  /// 注册根 [OverlayState]，若有 pending 则立即展示。
  void attach(
    OverlayState overlayState, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    _overlayState = overlayState;
    _navigatorKey = navigatorKey;
    _tryShowPending();
    _syncPopLock();
  }

  /// Updates the navigator used to lock the current route.
  /// 更新用于锁定当前路由的 Navigator。
  void updateNavigatorKey(GlobalKey<NavigatorState>? navigatorKey) {
    if (identical(_navigatorKey, navigatorKey)) {
      return;
    }
    _navigatorKey = navigatorKey;
    _syncPopLock();
  }

  /// Unregisters [overlayState] if it is the active host.
  /// 若 [overlayState] 是当前宿主则注销。
  ///
  /// The visible entry is removed; a pending or in-flight request is kept so
  /// the next attach can restore it.
  /// 会移除当前条目；pending 或正在展示的请求会保留，供下次挂载恢复。
  ///
  /// Omitting [overlayState] always detaches (used by tests).
  /// 省略 [overlayState] 时一律注销（测试用）。
  void detach([OverlayState? overlayState]) {
    if (overlayState != null &&
        _overlayState != null &&
        !identical(overlayState, _overlayState)) {
      return;
    }
    final FastLoadingRequest? restore = _isShowing ? _current : _pending;
    _removeEntry();
    _overlayState = null;
    _current = null;
    _isShowing = false;
    _pending = restore;
    _syncPopLock();
    _navigatorKey = null;
  }

  /// Shows [request], or stores it until an overlay is attached.
  /// 展示 [request]；尚未挂载 Overlay 时先记下，待挂载后再展示。
  ///
  /// Replaces the current overlay immediately when one is already visible.
  /// 若已有正在展示的 Loading，立即替换。
  void show(FastLoadingRequest request) {
    if (_overlayState == null) {
      _pending = request;
      return;
    }
    _pending = null;
    if (_isShowing) {
      _removeEntry();
      _isShowing = false;
      _current = null;
    }
    _current = request;
    _isShowing = true;
    _insert(request);
    _syncPopLock();
  }

  /// Plays exit animation for the current loading if one is showing.
  /// 若有当前 Loading，则播放退场动画。空闲时清空 pending。
  void dismiss() {
    if (!_isShowing || _current == null) {
      _pending = null;
      return;
    }
    _dismissCurrent?.call();
  }

  /// Removes the current entry immediately and drops any pending request.
  /// 立即移除当前条目并丢掉 pending。
  void dismissImmediate() {
    _pending = null;
    _removeEntry();
    _current = null;
    _isShowing = false;
    _syncPopLock();
  }

  /// Consumes the system back button while a locking loading is visible.
  /// Loading 展示且允许锁返回时，吃掉系统返回键。
  @override
  Future<bool> didPopRoute() async {
    return _shouldLockPop;
  }

  void _tryShowPending() {
    final FastLoadingRequest? pending = _pending;
    if (pending == null || _overlayState == null || _isShowing) {
      return;
    }
    _pending = null;
    _current = pending;
    _isShowing = true;
    _insert(pending);
  }

  void _insert(FastLoadingRequest request) {
    final OverlayState? overlayState = _overlayState;
    if (overlayState == null) {
      _current = null;
      _isShowing = false;
      _pending = request;
      _syncPopLock();
      return;
    }

    _removeEntry();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return FastLoadingView(
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
    _syncPopLock();
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

  bool get _shouldLockPop {
    return _isShowing && (_current?.config.lockPop ?? true);
  }

  void _syncPopLock() {
    if (_shouldLockPop) {
      _ensureBindingObserver();
      _lockCurrentRoute();
      return;
    }
    _unlockCurrentRoute();
    _removeBindingObserver();
  }

  void _lockCurrentRoute() {
    final NavigatorState? navigator = _navigatorKey?.currentState;
    ModalRoute<dynamic>? current;
    if (navigator != null) {
      navigator.popUntil((Route<dynamic> route) {
        if (route is ModalRoute<dynamic>) {
          current = route;
        }
        return true;
      });
    }
    if (identical(current, _lockedRoute) && _lockedRoute != null) {
      return;
    }
    _unlockCurrentRoute();
    final ModalRoute<dynamic>? next = current;
    if (next == null) {
      return;
    }
    next.registerPopEntry(_popLock);
    _lockedRoute = next;
  }

  void _unlockCurrentRoute() {
    final ModalRoute<dynamic>? route = _lockedRoute;
    _lockedRoute = null;
    if (route == null || !route.isActive) {
      return;
    }
    route.unregisterPopEntry(_popLock);
  }

  void _ensureBindingObserver() {
    if (_observingBinding) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _observingBinding = true;
  }

  void _removeBindingObserver() {
    if (!_observingBinding) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _observingBinding = false;
  }

  /// Test-only reset of singleton state.
  /// 仅测试用：重置单例状态。
  @visibleForTesting
  void resetForTest() {
    _pending = null;
    _removeEntry();
    _unlockCurrentRoute();
    _removeBindingObserver();
    _overlayState = null;
    _navigatorKey = null;
    _current = null;
    _isShowing = false;
  }
}

/// Blocks [ModalRoute.popDisposition] while registered on the current route.
/// 注册到当前路由后，让 [ModalRoute.popDisposition] 变为不可弹出。
final class _LoadingPopLock implements PopEntry<Object?> {
  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier<bool>(false);

  @override
  void onPopInvoked(bool didPop) {}

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {}
}
