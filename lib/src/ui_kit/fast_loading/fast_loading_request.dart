import 'package:flutter/widgets.dart';

import 'fast_loading_config.dart';

/// Loading payload: optional message, or a custom [WidgetBuilder].
/// Loading 载荷：可选文案，或自定义 [WidgetBuilder]。
final class FastLoadingRequest {
  /// Default spinner panel, with an optional [message].
  /// 默认转圈面板；[message] 可选。
  const FastLoadingRequest.standard({
    this.message,
    this.config = const FastLoadingConfig(),
  }) : builder = null;

  /// Custom-widget loading; the host does not wrap default panel chrome.
  /// 自定义 Widget Loading；宿主不再套默认面板。
  const FastLoadingRequest.custom(
    this.builder, {
    this.config = const FastLoadingConfig(),
  }) : message = null;

  /// Message under the spinner; `null` or empty hides the label.
  /// 转圈下方的文案；`null` 或空字符串时不展示。
  final String? message;

  /// Builds custom content; `null` when using the default panel.
  /// 构建自定义内容；使用默认面板时为 `null`。
  final WidgetBuilder? builder;

  /// Behavior config for this request.
  /// 本次请求的行为配置。
  final FastLoadingConfig config;

  /// Whether this request uses custom content.
  /// 是否为自定义 Loading。
  bool get isCustom => builder != null;

  /// Whether the default panel should render a message.
  /// 默认面板是否需要展示文案。
  bool get hasMessage => message != null && message!.trim().isNotEmpty;
}
