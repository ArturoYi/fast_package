part of 'fast_refresh.dart';

/// Classic Header / Footer 的一组状态文案。
class FastRefreshIndicatorTexts {
  /// 创建文案组。
  const FastRefreshIndicatorTexts({
    required this.dragText,
    required this.armedText,
    required this.readyText,
    required this.processingText,
    required this.processedText,
    required this.noMoreText,
    required this.failedText,
    required this.messageText,
  });

  /// [FastRefreshMode.drag] 文案。
  final String dragText;

  /// [FastRefreshMode.armed] 文案。
  final String armedText;

  /// [FastRefreshMode.ready] 文案。
  final String readyText;

  /// [FastRefreshMode.processing] 文案。
  final String processingText;

  /// [FastRefreshMode.processed] 成功文案。
  final String processedText;

  /// [FastRefreshResult.noMore] 文案。
  final String noMoreText;

  /// [FastRefreshResult.fail] 文案。
  final String failedText;

  /// 次要信息。`%T` 会被替换为上次更新的 HH:mm。
  final String messageText;

  /// Classic Header 的英文默认文案。
  static const FastRefreshIndicatorTexts headerEnglish =
      FastRefreshIndicatorTexts(
    dragText: 'Pull to refresh',
    armedText: 'Release ready',
    readyText: 'Refreshing...',
    processingText: 'Refreshing...',
    processedText: 'Succeeded',
    noMoreText: 'No more',
    failedText: 'Failed',
    messageText: 'Last updated at %T',
  );

  /// Classic Footer 的英文默认文案。
  static const FastRefreshIndicatorTexts footerEnglish =
      FastRefreshIndicatorTexts(
    dragText: 'Pull to load',
    armedText: 'Release ready',
    readyText: 'Loading...',
    processingText: 'Loading...',
    processedText: 'Succeeded',
    noMoreText: 'No more',
    failedText: 'Failed',
    messageText: 'Last updated at %T',
  );

  /// 用 [other] 的非空字段覆盖。
  FastRefreshIndicatorTexts copyWith({
    String? dragText,
    String? armedText,
    String? readyText,
    String? processingText,
    String? processedText,
    String? noMoreText,
    String? failedText,
    String? messageText,
  }) {
    return FastRefreshIndicatorTexts(
      dragText: dragText ?? this.dragText,
      armedText: armedText ?? this.armedText,
      readyText: readyText ?? this.readyText,
      processingText: processingText ?? this.processingText,
      processedText: processedText ?? this.processedText,
      noMoreText: noMoreText ?? this.noMoreText,
      failedText: failedText ?? this.failedText,
      messageText: messageText ?? this.messageText,
    );
  }

  /// 在两组文案之间按 [t] 切换（文案不插值）。
  FastRefreshIndicatorTexts lerp(FastRefreshIndicatorTexts other, double t) {
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FastRefreshIndicatorTexts &&
        other.dragText == dragText &&
        other.armedText == armedText &&
        other.readyText == readyText &&
        other.processingText == processingText &&
        other.processedText == processedText &&
        other.noMoreText == noMoreText &&
        other.failedText == failedText &&
        other.messageText == messageText;
  }

  @override
  int get hashCode => Object.hash(
        dragText,
        armedText,
        readyText,
        processingText,
        processedText,
        noMoreText,
        failedText,
        messageText,
      );
}

/// Classic / Material 指示器外观。不改变触发距离或弹簧。
///
/// 解析顺序：组件构造参数 → 已注册的 [FastRefreshTheme] →
/// 按 [ThemeData.brightness] 回退的 [light] / [dark]。
class FastRefreshTheme extends ThemeExtension<FastRefreshTheme> {
  /// 创建刷新主题。
  const FastRefreshTheme({
    required this.headerTexts,
    required this.footerTexts,
    this.textStyle,
    this.messageStyle,
    this.iconTheme,
    this.progressIndicatorSize,
    this.progressIndicatorStrokeWidth,
    this.indicatorColor,
    this.backgroundColor,
  });

  /// Classic Header 文案。
  final FastRefreshIndicatorTexts headerTexts;

  /// Classic Footer 文案。
  final FastRefreshIndicatorTexts footerTexts;

  /// Classic 状态文案样式。
  final TextStyle? textStyle;

  /// Classic 次要信息样式。
  final TextStyle? messageStyle;

  /// Classic 图标主题。
  final IconThemeData? iconTheme;

  /// Classic / Material 进度圈尺寸。
  final double? progressIndicatorSize;

  /// Classic / Material 进度圈线宽。
  final double? progressIndicatorStrokeWidth;

  /// Material 指示器颜色。未设置时用 [ColorScheme.primary]。
  final Color? indicatorColor;

  /// Material 指示器背景色。
  final Color? backgroundColor;

  /// 亮色回退：英文 Classic 文案，不指定 Material 颜色。
  static const FastRefreshTheme light = FastRefreshTheme(
    headerTexts: FastRefreshIndicatorTexts.headerEnglish,
    footerTexts: FastRefreshIndicatorTexts.footerEnglish,
  );

  /// 暗色回退：与 [light] 相同的英文文案。
  static const FastRefreshTheme dark = FastRefreshTheme(
    headerTexts: FastRefreshIndicatorTexts.headerEnglish,
    footerTexts: FastRefreshIndicatorTexts.footerEnglish,
  );

  /// 读取已注册的扩展；未注册时为 `null`。
  static FastRefreshTheme? of(BuildContext context) {
    return Theme.of(context).extension<FastRefreshTheme>();
  }

  /// 解析 [context] 下的有效主题。
  static FastRefreshTheme resolve(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return of(context) ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  FastRefreshTheme copyWith({
    FastRefreshIndicatorTexts? headerTexts,
    FastRefreshIndicatorTexts? footerTexts,
    TextStyle? textStyle,
    TextStyle? messageStyle,
    IconThemeData? iconTheme,
    double? progressIndicatorSize,
    double? progressIndicatorStrokeWidth,
    Color? indicatorColor,
    Color? backgroundColor,
  }) {
    return FastRefreshTheme(
      headerTexts: headerTexts ?? this.headerTexts,
      footerTexts: footerTexts ?? this.footerTexts,
      textStyle: textStyle ?? this.textStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      progressIndicatorSize:
          progressIndicatorSize ?? this.progressIndicatorSize,
      progressIndicatorStrokeWidth:
          progressIndicatorStrokeWidth ?? this.progressIndicatorStrokeWidth,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  FastRefreshTheme lerp(FastRefreshTheme? other, double t) {
    if (other == null) {
      return this;
    }
    return FastRefreshTheme(
      headerTexts: headerTexts.lerp(other.headerTexts, t),
      footerTexts: footerTexts.lerp(other.footerTexts, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
      iconTheme: IconThemeData.lerp(iconTheme, other.iconTheme, t),
      progressIndicatorSize:
          lerpDouble(progressIndicatorSize, other.progressIndicatorSize, t),
      progressIndicatorStrokeWidth: lerpDouble(
        progressIndicatorStrokeWidth,
        other.progressIndicatorStrokeWidth,
        t,
      ),
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FastRefreshTheme &&
        other.headerTexts == headerTexts &&
        other.footerTexts == footerTexts &&
        other.textStyle == textStyle &&
        other.messageStyle == messageStyle &&
        other.iconTheme == iconTheme &&
        other.progressIndicatorSize == progressIndicatorSize &&
        other.progressIndicatorStrokeWidth == progressIndicatorStrokeWidth &&
        other.indicatorColor == indicatorColor &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
        headerTexts,
        footerTexts,
        textStyle,
        messageStyle,
        iconTheme,
        progressIndicatorSize,
        progressIndicatorStrokeWidth,
        indicatorColor,
        backgroundColor,
      );
}
