part of '../fast_refresh.dart';

/// 默认上拉 / 触底加载 Footer（箭头 + 文案 + 转圈）。
class FastClassicFooter extends FastRefreshFooter {
  /// 传给指示器主体的 [Key]。
  final Key? key;

  /// 指示器在越界区域内的对齐。仅支持 start / center / end。
  final MainAxisAlignment mainAxisAlignment;

  /// 背景色。设置了 [boxDecoration] 时忽略。
  final Color? backgroundColor;

  /// 背景装饰。
  final BoxDecoration? boxDecoration;

  /// [FastRefreshMode.drag] 文案。
  final String? dragText;

  /// [FastRefreshMode.armed] 文案。
  final String? armedText;

  /// [FastRefreshMode.ready] 文案。
  final String? readyText;

  /// [FastRefreshMode.processing] 文案。
  final String? processingText;

  /// [FastRefreshMode.processed] 成功文案。
  final String? processedText;

  /// [FastRefreshResult.noMore] 文案。
  final String? noMoreText;

  /// [FastRefreshResult.fail] 文案。
  final String? failedText;

  /// 是否显示状态文案。
  final bool showText;

  /// 次要信息。`%T` 会被替换为上次更新的 HH:mm。
  final String? messageText;

  /// 是否显示次要信息。
  final bool showMessage;

  /// 文案区域宽度 / 高度。小于 0 时按文字实际尺寸计算。
  final double? textDimension;

  /// 图标区域尺寸。
  final double iconDimension;

  /// 图标与文案间距。
  final double spacing;

  /// 成功图标。
  final Widget? succeededIcon;

  /// 失败图标。
  final Widget? failedIcon;

  /// 无更多图标。
  final Widget? noMoreIcon;

  /// 拉动过程中的图标构建器。
  final FastClassicPullIconBuilder? pullIconBuilder;

  /// 状态文案样式。
  final TextStyle? textStyle;

  /// 自定义状态文案组件。
  final FastClassicTextBuilder? textBuilder;

  /// 次要信息样式。
  final TextStyle? messageStyle;

  /// 自定义次要信息组件。
  final FastClassicMessageBuilder? messageBuilder;

  /// 见 [Stack.clipBehavior]。
  final Clip clipBehavior;

  /// 图标主题。
  final IconThemeData? iconTheme;

  /// 进度圈尺寸。
  final double? progressIndicatorSize;

  /// 进度圈线宽。见 [CircularProgressIndicator.strokeWidth]。
  final double? progressIndicatorStrokeWidth;

  /// 创建 Classic Footer。默认 [infiniteOffset] 为 70，未传文案时使用英文默认值。
  const FastClassicFooter({
    this.key,
    super.triggerOffset = 70,
    super.clamping = false,
    super.position,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.safeArea,
    super.infiniteOffset = 70,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.backgroundColor,
    this.boxDecoration,
    this.dragText,
    this.armedText,
    this.readyText,
    this.processingText,
    this.processedText,
    this.noMoreText,
    this.failedText,
    this.showText = true,
    this.messageText,
    this.showMessage = true,
    this.textDimension,
    this.iconDimension = 24,
    this.spacing = 16,
    this.succeededIcon,
    this.failedIcon,
    this.noMoreIcon,
    this.pullIconBuilder,
    this.textStyle,
    this.textBuilder,
    this.messageStyle,
    this.messageBuilder,
    this.clipBehavior = Clip.hardEdge,
    this.iconTheme,
    this.progressIndicatorSize,
    this.progressIndicatorStrokeWidth,
  });

  @override
  Widget build(BuildContext context, FastRefreshIndicatorState state) {
    return _FastClassicIndicator(
      key: key,
      state: state,
      backgroundColor: backgroundColor,
      boxDecoration: boxDecoration,
      mainAxisAlignment: mainAxisAlignment,
      dragText: dragText ?? 'Pull to load',
      armedText: armedText ?? 'Release ready',
      readyText: readyText ?? 'Loading...',
      processingText: processingText ?? 'Loading...',
      processedText: processedText ?? 'Succeeded',
      noMoreText: noMoreText ?? 'No more',
      failedText: failedText ?? 'Failed',
      showText: showText,
      messageText: messageText ?? 'Last updated at %T',
      showMessage: showMessage,
      textDimension: textDimension,
      iconDimension: iconDimension,
      spacing: spacing,
      reverse: !state.reverse,
      succeededIcon: succeededIcon,
      failedIcon: failedIcon,
      noMoreIcon: noMoreIcon,
      pullIconBuilder: pullIconBuilder,
      textStyle: textStyle,
      textBuilder: textBuilder,
      messageStyle: messageStyle,
      messageBuilder: messageBuilder,
      clipBehavior: clipBehavior,
      iconTheme: iconTheme,
      progressIndicatorSize: progressIndicatorSize,
      progressIndicatorStrokeWidth: progressIndicatorStrokeWidth,
    );
  }
}
