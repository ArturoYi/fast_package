import 'package:flutter/widgets.dart';

import 'fast_toast_config.dart';

/// Enqueued toast payload: either a text message or a custom [Widget].
/// 入队的 Toast 载荷：纯文本或自定义 [Widget]。
final class FastToastRequest {
  /// Text toast shown with the default themed panel.
  /// 使用默认主题面板展示的文本 Toast。
  const FastToastRequest.text(
    this.message, {
    this.config = const FastToastConfig(),
  }) : child = null;

  /// Custom-widget toast; the host does not wrap default panel chrome.
  /// 自定义 Widget Toast；宿主不再套默认面板。
  const FastToastRequest.custom(
    this.child, {
    this.config = const FastToastConfig(),
  }) : message = null;

  /// Message for a text toast; `null` when [child] is set.
  /// 文本 Toast 的文案；设置 [child] 时为 `null`。
  final String? message;

  /// Custom content; `null` when [message] is set.
  /// 自定义内容；设置 [message] 时为 `null`。
  final Widget? child;

  /// Behavior config for this request.
  /// 本条请求的行为配置。
  final FastToastConfig config;

  /// Whether this request is a text toast.
  /// 是否为文本 Toast。
  bool get isText => message != null;
}

/// FIFO pending queue for toast requests.
/// Toast 请求的 FIFO 待展示队列。
final class FastToastQueue {
  /// Max pending items, excluding the toast currently on screen.
  /// 待展示上限（不含当前正在展示的一条）。
  static const int maxPending = 5;

  final List<FastToastRequest> _items = <FastToastRequest>[];

  /// Number of pending requests.
  /// 待展示条数。
  int get length => _items.length;

  /// Whether the queue is empty.
  /// 队列是否为空。
  bool get isEmpty => _items.isEmpty;

  /// Whether the queue has at least one pending request.
  /// 队列是否至少有一条待展示。
  bool get isNotEmpty => _items.isNotEmpty;

  /// Oldest pending request, or `null` if empty.
  /// 最旧的待展示请求；空则 `null`。
  FastToastRequest? get first => isEmpty ? null : _items.first;

  /// Appends [request]; drops the oldest pending item when full.
  /// 追加 [request]；满时丢掉最旧 pending。
  void enqueue(FastToastRequest request) {
    if (_items.length >= maxPending) {
      _items.removeAt(0);
    }
    _items.add(request);
  }

  /// Removes and returns the oldest pending request, or `null` if empty.
  /// 取出最旧待展示请求；空则 `null`。
  FastToastRequest? dequeue() {
    if (_items.isEmpty) {
      return null;
    }
    return _items.removeAt(0);
  }

  /// Removes all pending requests.
  /// 清空待展示队列。
  void clear() {
    _items.clear();
  }
}
