part of '../fast_refresh.dart';

/// 拉动过程中的图标构建器。
typedef FastClassicPullIconBuilder = Widget Function(
    BuildContext context, FastRefreshIndicatorState state, double animation);

/// 状态文案构建器。
typedef FastClassicTextBuilder = Widget Function(
    BuildContext context, FastRefreshIndicatorState state, String text);

/// 次要信息构建器。
typedef FastClassicMessageBuilder = Widget Function(
    BuildContext context, FastRefreshIndicatorState state, String text, DateTime dateTime);

/// 默认进度圈尺寸。
const _kDefaultProgressIndicatorSize = 20.0;

/// 默认进度圈线宽。
const _kDefaultProgressIndicatorStrokeWidth = 2.0;

/// Classic 指示器主体，供 [FastClassicHeader] / [FastClassicFooter] 共用。
class _FastClassicIndicator extends StatefulWidget {
  /// 当前指示器快照。
  final FastRefreshIndicatorState state;

  /// 指示器在越界区域内的对齐。仅支持 start / center / end。
  final MainAxisAlignment mainAxisAlignment;

  /// 背景色。设置了 [boxDecoration] 时忽略。
  final Color? backgroundColor;

  /// 背景装饰。
  final BoxDecoration? boxDecoration;

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

  /// 是否显示状态文案。
  final bool showText;

  /// 次要信息。`%T` 会被替换为上次更新的 HH:mm。
  final String messageText;

  /// 是否显示次要信息。
  final bool showMessage;

  /// 文案区域宽度 / 高度。小于 0 时按文字实际尺寸计算。
  final double? textDimension;

  /// 图标区域尺寸。
  final double iconDimension;

  /// 图标与文案间距。
  final double spacing;

  /// `true` 表示向上 / 向左；`false` 表示向下 / 向右。
  final bool reverse;

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

  /// 创建 Classic 指示器主体。
  const _FastClassicIndicator({
    super.key,
    required this.state,
    required this.mainAxisAlignment,
    this.backgroundColor,
    this.boxDecoration,
    required this.dragText,
    required this.armedText,
    required this.readyText,
    required this.processingText,
    required this.processedText,
    required this.noMoreText,
    required this.failedText,
    this.showText = true,
    required this.messageText,
    required this.reverse,
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
  }) : assert(
            mainAxisAlignment == MainAxisAlignment.start ||
                mainAxisAlignment == MainAxisAlignment.center ||
                mainAxisAlignment == MainAxisAlignment.end,
            'Only supports [MainAxisAlignment.center], [MainAxisAlignment.start] and [MainAxisAlignment.end].');

  @override
  State<_FastClassicIndicator> createState() => _ClassicFastRefreshIndicatorState();
}

/// Classic 指示器状态：箭头旋转、文案切换、安全区定位。
class _ClassicFastRefreshIndicatorState extends State<_FastClassicIndicator>
    with TickerProviderStateMixin<_FastClassicIndicator> {
  /// 图标切换动画的 key。
  late GlobalKey _iconAnimatedSwitcherKey;

  /// 上次进入 processed 的时间，用于 %T。
  late DateTime _updateTime;

  /// 箭头旋转动画：drag → armed 翻转到 1，退回时转回 0。
  late AnimationController _iconAnimationController;

  /// 指示器在越界区域内的对齐。
  MainAxisAlignment get _mainAxisAlignment => widget.mainAxisAlignment;

  /// 当前滚动轴。
  Axis get _axis => widget.state.axis;

  /// 当前越界偏移。
  double get _offset => widget.state.offset;

  /// 实际触发距离（含安全区）。
  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  /// 配置上的触发距离。
  double get _triggerOffset => widget.state.triggerOffset;

  /// 安全区计入的额外距离。
  double get _safeOffset => widget.state.safeOffset;

  /// 当前生命周期。
  FastRefreshMode get _mode => widget.state.mode;

  /// 最近一次任务结果。
  FastRefreshResult get _result => widget.state.result;

  @override
  void initState() {
    super.initState();
    _iconAnimatedSwitcherKey = GlobalKey();
    _updateTime = DateTime.now();
    _iconAnimationController = AnimationController(
      value: 0,
      vsync: this,
      duration: const Duration(microseconds: 200),
    );
    _iconAnimationController.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_FastClassicIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 进入 processed 时刷新「上次更新」时间。
    if (widget.state.mode == FastRefreshMode.processed &&
        oldWidget.state.mode != FastRefreshMode.processed) {
      _updateTime = DateTime.now();
    }
    if (widget.state.mode == FastRefreshMode.armed &&
        oldWidget.state.mode == FastRefreshMode.drag) {
      // 到达阈值：箭头翻转。
      _iconAnimationController.animateTo(1,
          duration: const Duration(milliseconds: 200));
    } else if (widget.state.mode == FastRefreshMode.drag &&
        oldWidget.state.mode == FastRefreshMode.armed) {
      // 退回阈值以下：箭头转回。
      _iconAnimationController.animateBack(0,
          duration: const Duration(milliseconds: 200));
    } else if (widget.state.mode == FastRefreshMode.processing &&
        oldWidget.state.mode != FastRefreshMode.processing) {
      // 进入转圈：箭头旋转进度清零，避免下次拉动残留。
      _iconAnimationController.reset();
    }
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  /// 当前模式对应的状态文案。
  String get _currentText {
    if (_result == FastRefreshResult.noMore) {
      return widget.noMoreText;
    }
    switch (_mode) {
      case FastRefreshMode.drag:
        return widget.dragText;
      case FastRefreshMode.armed:
        return widget.armedText;
      case FastRefreshMode.ready:
        return widget.readyText;
      case FastRefreshMode.processing:
        return widget.processingText;
      case FastRefreshMode.processed:
      case FastRefreshMode.done:
        if (_result == FastRefreshResult.fail) {
          return widget.failedText;
        } else {
          return widget.processedText;
        }
      default:
        return widget.dragText;
    }
  }

  /// 次要信息（把 `%T` 换成 HH:mm）。
  String get _messageText {
    if (widget.messageText.contains('%T')) {
      String fillChar = _updateTime.minute < 10 ? "0" : "";
      return widget.messageText.replaceAll(
          "%T", "${_updateTime.hour}:$fillChar${_updateTime.minute}");
    }
    return widget.messageText;
  }

  /// 按模式 / 结果选择图标，并用 [AnimatedSwitcher] 过渡。
  Widget _buildIcon() {
    if (widget.pullIconBuilder != null) {
      return widget.pullIconBuilder!
          .call(context, widget.state, _iconAnimationController.value);
    }
    Widget icon;
    final iconTheme = widget.iconTheme ?? Theme.of(context).iconTheme;
    ValueKey iconKey;
    if (_result == FastRefreshResult.noMore) {
      iconKey = const ValueKey(FastRefreshResult.noMore);
      icon = SizedBox(
        child: widget.noMoreIcon ??
            const Icon(
              Icons.inbox_outlined,
            ),
      );
    } else if (_mode == FastRefreshMode.processing ||
        _mode == FastRefreshMode.ready) {
      iconKey = const ValueKey(FastRefreshMode.processing);
      final progressIndicatorSize =
          widget.progressIndicatorSize ?? _kDefaultProgressIndicatorSize;
      icon = SizedBox(
        width: progressIndicatorSize,
        height: progressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: widget.progressIndicatorStrokeWidth ??
              _kDefaultProgressIndicatorStrokeWidth,
          color: iconTheme.color,
        ),
      );
    } else if (_mode == FastRefreshMode.processed ||
        _mode == FastRefreshMode.done) {
      if (_result == FastRefreshResult.fail) {
        iconKey = const ValueKey(FastRefreshResult.fail);
        icon = SizedBox(
          child: widget.failedIcon ??
              const Icon(
                Icons.error_outline,
              ),
        );
      } else {
        iconKey = const ValueKey(FastRefreshResult.success);
        icon = SizedBox(
          child: widget.succeededIcon ??
              Transform.rotate(
                angle: _axis == Axis.vertical ? 0 : -math.pi / 2,
                child: const Icon(
                  Icons.done,
                ),
              ),
        );
      }
    } else {
      iconKey = const ValueKey(FastRefreshMode.drag);
      icon = SizedBox(
        child: Transform.rotate(
          angle: -math.pi * _iconAnimationController.value,
          child: Icon(widget.reverse
              ? (_axis == Axis.vertical ? Icons.arrow_upward : Icons.arrow_back)
              : (_axis == Axis.vertical
                  ? Icons.arrow_downward
                  : Icons.arrow_forward)),
        ),
      );
    }
    return AnimatedSwitcher(
      key: _iconAnimatedSwitcherKey,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: IconTheme(
        key: iconKey,
        data: iconTheme,
        child: icon,
      ),
    );
  }

  /// 构建状态文案。
  Widget _buildText() {
    return widget.textBuilder?.call(context, widget.state, _currentText) ??
        Text(
          _currentText,
          style: widget.textStyle ?? Theme.of(context).textTheme.titleMedium,
        );
  }

  /// 构建次要信息。
  Widget _buildMessage() {
    return widget.messageBuilder
            ?.call(context, widget.state, widget.messageText, _updateTime) ??
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _messageText,
            style: widget.messageStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        );
  }

  /// 垂直列表的指示器布局。
  Widget _buildVerticalWidget() {
    return Stack(
      clipBehavior: widget.clipBehavior,
      children: [
        if (_mainAxisAlignment == MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _offset < _actualTriggerOffset
                ? -(_actualTriggerOffset -
                        _offset +
                        (widget.reverse ? _safeOffset : -_safeOffset)) /
                    2
                : (!widget.reverse ? _safeOffset : 0),
            bottom: _offset < _actualTriggerOffset
                ? null
                : (widget.reverse ? _safeOffset : 0),
            height:
                _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
            child: Center(
              child: _buildVerticalBody(),
            ),
          ),
        if (_mainAxisAlignment != MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _mainAxisAlignment == MainAxisAlignment.start
                ? (!widget.reverse ? _safeOffset : 0)
                : null,
            bottom: _mainAxisAlignment == MainAxisAlignment.end
                ? (widget.reverse ? _safeOffset : 0)
                : null,
            child: _buildVerticalBody(),
          ),
      ],
    );
  }

  /// 垂直方向的图标 + 文案。
  Widget _buildVerticalBody() {
    return Container(
      alignment: Alignment.center,
      height: _triggerOffset,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: widget.iconDimension,
            child: _buildIcon(),
          ),
          if (widget.showText)
            Container(
              margin: EdgeInsets.only(left: widget.spacing),
              width: widget.textDimension,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText(),
                  if (widget.showMessage) _buildMessage(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 水平列表的指示器布局。
  Widget _buildHorizontalWidget() {
    return Stack(
      clipBehavior: widget.clipBehavior,
      children: [
        if (_mainAxisAlignment == MainAxisAlignment.center)
          Positioned(
            left: _offset < _actualTriggerOffset
                ? -(_actualTriggerOffset -
                        _offset +
                        (widget.reverse ? _safeOffset : -_safeOffset)) /
                    2
                : (!widget.reverse ? _safeOffset : 0),
            right: _offset < _actualTriggerOffset
                ? null
                : (widget.reverse ? _safeOffset : 0),
            top: 0,
            bottom: 0,
            width: _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
            child: Center(
              child: _buildHorizontalBody(),
            ),
          ),
        if (_mainAxisAlignment != MainAxisAlignment.center)
          Positioned(
            left: _mainAxisAlignment == MainAxisAlignment.start
                ? (!widget.reverse ? _safeOffset : 0)
                : null,
            right: _mainAxisAlignment == MainAxisAlignment.end
                ? (widget.reverse ? _safeOffset : 0)
                : null,
            top: 0,
            bottom: 0,
            child: _buildHorizontalBody(),
          ),
      ],
    );
  }

  /// 水平方向的图标 + 文案。
  Widget _buildHorizontalBody() {
    return Container(
      alignment: Alignment.center,
      width: _triggerOffset,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showText)
            Container(
              margin: EdgeInsets.only(bottom: widget.spacing),
              width: widget.textDimension,
              child: RotatedBox(
                quarterTurns: -1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(),
                    if (widget.showMessage) _buildMessage(),
                  ],
                ),
              ),
            ),
          Container(
            alignment: Alignment.center,
            height: widget.iconDimension,
            child: _buildIcon(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double offset = _offset;
    // locator + 无限滚动：任务进行中或 noMore 时固定占实际触发高度，
    // 避免指示器随列表回弹被挤没。
    if (widget.state.indicator.infiniteOffset != null &&
        widget.state.indicator.position == FastRefreshIndicatorPosition.locator &&
        (_mode != FastRefreshMode.inactive ||
            _result == FastRefreshResult.noMore)) {
      offset = _actualTriggerOffset;
    }
    return Container(
      color: widget.boxDecoration == null ? widget.backgroundColor : null,
      decoration: widget.boxDecoration,
      width: _axis == Axis.vertical ? double.infinity : offset,
      height: _axis == Axis.horizontal ? double.infinity : offset,
      child: _axis == Axis.vertical
          ? _buildVerticalWidget()
          : _buildHorizontalWidget(),
    );
  }
}
