import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fast_shimmer_highlight.dart';

/// Where the decorative beam is applied on a [FastShimmerSlideUnlock].
/// [FastShimmerSlideUnlock] 上细光束的贴法。
///
/// Both variants share the same timing: a ~3 s left-to-right sweep across
/// the **slider bounds**, then a ~1.8 s pause. Only opaque pixels inside the
/// chosen target light up; the page / card behind the control stays still.
/// 两种贴法共用同一套时序：约 3 秒沿**滑块区域**从左扫到右，再停约 1.8 秒。
/// 只有所选目标里的不透明像素会发亮；控件背后的页面 / 卡片保持不动。
enum FastShimmerSlideUnlockHighlight {
  /// Sweep the whole capsule (metal-bar sheen). Label and thumb sit on top.
  /// 整条滑块区域扫光（金属条高光）。文案和滑钮叠在上面。
  area,

  /// Sweep only the hint glyphs. Track and thumb stay still.
  /// 仅文字高光。轨道和滑钮不动。
  label,
}

/// A draggable capsule slider with a thin highlight beam.
/// 带细光束扫光的可拖动胶囊滑轨。
///
/// [highlight] chooses the mask target; [duration] / [pauseDuration] stay
/// shared. The label does **not** fade while dragging.
/// [highlight] 选择遮罩目标；[duration] / [pauseDuration] 两种贴法共用。
/// 拖动时文案**不会**变浅。
///
/// Crossing [threshold] completes the slide and calls [onUnlocked].
/// Otherwise the thumb springs back. [resetOnUnlock] returns it to the start.
/// 超过 [threshold] 即完成滑动并回调 [onUnlocked]；否则滑块回弹。
/// [resetOnUnlock] 会在解锁后再把滑块复位。
///
/// ```dart
/// FastShimmerSlideUnlock(
///   label: '滑动解锁',
///   highlight: FastShimmerSlideUnlockHighlight.area,
///   resetOnUnlock: true,
///   onUnlocked: _unlock,
/// )
/// ```
class FastShimmerSlideUnlock extends StatefulWidget {
  /// Creates a slide-to-unlock control with a decorative beam.
  /// 创建一个带装饰性光束的滑动解锁控件。
  const FastShimmerSlideUnlock({
    super.key,
    this.label = '滑动解锁',
    this.successLabel,
    this.onUnlocked,
    this.height = 60,
    this.thumbSize = 52,
    this.threshold = 0.85,
    this.enabled = true,
    this.resetOnUnlock = true,
    this.highlight = FastShimmerSlideUnlockHighlight.label,
    this.trackColor,
    this.thumbColor = Colors.white,
    this.thumbIcon,
    this.successIcon,
    this.labelStyle,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.pauseDuration,
  });

  /// Hint text that receives the highlight sweep.
  /// 接收扫光的提示文案。
  final String label;

  /// Optional label shown after a successful unlock (still no fade).
  /// 解锁成功后展示的文案（同样不变浅）；可空。
  final String? successLabel;

  /// Called once when the slide crosses [threshold] and settles at the end.
  /// 当滑动越过 [threshold] 并就位到终点时回调一次。
  final VoidCallback? onUnlocked;

  /// Track height in logical pixels.
  /// 轨道高度（逻辑像素）。
  final double height;

  /// Thumb diameter; clamped so it always fits inside [height].
  /// 滑块直径；会被钳制以保证始终放得进 [height]。
  final double thumbSize;

  /// Progress (`0`–`1`) required to unlock. Must be in `(0, 1]`.
  /// 解锁所需进度（`0`–`1`），必须落在 `(0, 1]`。
  final double threshold;

  /// When `false`, the thumb cannot be dragged.
  /// 为 `false` 时不可拖动。
  final bool enabled;

  /// When `true`, the thumb returns to the start after [onUnlocked].
  /// 为 `true` 时，在 [onUnlocked] 之后滑块回到起点。
  final bool resetOnUnlock;

  /// Beam target: the whole capsule, or only the hint text.
  /// 光束目标：整条胶囊，或仅提示文案。
  ///
  /// Both use the same [duration] / [pauseDuration] and travel the slider
  /// width. Default is [FastShimmerSlideUnlockHighlight.label].
  /// 两种贴法共用 [duration] / [pauseDuration]，并沿滑块宽度扫过。
  /// 默认 [FastShimmerSlideUnlockHighlight.label]。
  final FastShimmerSlideUnlockHighlight highlight;

  /// Track fill color. Defaults to a dark capsule.
  /// 轨道填充色，默认深色胶囊。
  ///
  /// In [FastShimmerSlideUnlockHighlight.area] the visible metal tone comes
  /// from [baseColor] / [highlightColor]; this fill only supplies opacity.
  /// [FastShimmerSlideUnlockHighlight.area] 下可见金属色来自 [baseColor] /
  /// [highlightColor]；此处填充只提供不透明度。
  final Color? trackColor;

  /// Thumb fill color.
  /// 滑块填充色。
  final Color thumbColor;

  /// Icon shown on the thumb before unlock.
  /// 解锁前滑块上的图标。
  final IconData? thumbIcon;

  /// Icon shown on the thumb after unlock.
  /// 解锁后滑块上的图标。
  final IconData? successIcon;

  /// Style for [label] / [successLabel]. In [FastShimmerSlideUnlockHighlight.label]
  /// the glyph color is owned by the beam; in `area` the painted color is kept.
  /// [label] / [successLabel] 的样式。[FastShimmerSlideUnlockHighlight.label]
  /// 下字形色由光束接管；`area` 下保留绘制色。
  final TextStyle? labelStyle;

  /// Shimmer base color. Defaults to metal gray for [highlight] `area`,
  /// and dim white for `label`.
  /// 扫光底色。[highlight] 为 `area` 时默认金属灰，`label` 时默认浅白。
  final Color? baseColor;

  /// Shimmer highlight color. Defaults to white.
  /// 扫光高光色，默认白色。
  final Color? highlightColor;

  /// Highlight sweep length. Defaults to [FastShimmerHighlight.defaultDuration].
  /// 扫光时长。默认 [FastShimmerHighlight.defaultDuration]。
  final Duration? duration;

  /// Pause after the beam exits. Defaults to
  /// [FastShimmerHighlight.defaultPauseDuration].
  /// 光束离开后的停顿。默认 [FastShimmerHighlight.defaultPauseDuration]。
  final Duration? pauseDuration;

  @override
  State<FastShimmerSlideUnlock> createState() => _FastShimmerSlideUnlockState();
}

class _FastShimmerSlideUnlockState extends State<FastShimmerSlideUnlock>
    with SingleTickerProviderStateMixin {
  /// `0` = start, `1` = unlocked end. Also drives settle animations.
  /// `0` 为起点，`1` 为解锁终点；同时驱动回弹 / 就位动画。
  late final AnimationController _progress;

  /// True while a finger is dragging. Mutes the beam ticker without
  /// rebuilding the [GestureDetector].
  /// 手指拖动中为真。只停掉光束 ticker，不重建 [GestureDetector]。
  final ValueNotifier<bool> _holdSheen = ValueNotifier<bool>(false);

  /// Whether a successful unlock has been committed.
  /// 是否已经完成一次成功解锁。
  bool _unlocked = false;

  /// Guards overlapping drag-end / reset sequences.
  /// 防止松手就位与复位流程重叠。
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(FastShimmerSlideUnlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled && !_unlocked) {
      _progress.value = 0;
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _holdSheen.dispose();
    super.dispose();
  }

  /// Drag is read at event time so a settle animation does not have to
  /// rebuild the recognizer to re-enable the next swipe.
  /// 在事件里读拖动态。回弹动画不必为了恢复下一次滑动而重建手势。
  bool get _acceptsDrag => widget.enabled && !_unlocked && !_settling;

  /// True when reduce-motion is on; settle jumps instead of animating.
  /// 开启「减少动态效果」时为真；就位改为跳变而不是动画。
  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  void _onDragStart(DragStartDetails details) {
    if (!_acceptsDrag) {
      return;
    }
    _holdSheen.value = true;
  }

  void _onDragUpdate(DragUpdateDetails details, double maxTravel, bool rtl) {
    if (!_acceptsDrag || maxTravel <= 0) {
      return;
    }
    final double delta = rtl ? -details.delta.dx : details.delta.dx;
    _progress.value = (_progress.value + delta / maxTravel).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails _) {
    _holdSheen.value = false;
    if (!_acceptsDrag) {
      return;
    }
    _onDragEnd();
  }

  void _handleDragCancel() {
    _holdSheen.value = false;
    if (!_acceptsDrag) {
      return;
    }
    _onDragEnd();
  }

  Future<void> _onDragEnd() async {
    if (_unlocked || _settling) {
      return;
    }
    final bool shouldUnlock = _progress.value >= widget.threshold;
    await _settle(shouldUnlock ? 1.0 : 0.0, unlock: shouldUnlock);
  }

  Future<void> _settle(double target, {required bool unlock}) async {
    _settling = true;
    if (_reduceMotion) {
      _progress.value = target;
    } else {
      await _progress.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) {
      return;
    }
    if (unlock && target >= 1.0) {
      await _handleUnlock();
    }
    if (mounted) {
      _settling = false;
    }
  }

  Future<void> _handleUnlock() async {
    if (_unlocked) {
      return;
    }
    setState(() => _unlocked = true);
    widget.onUnlocked?.call();
    await HapticFeedback.mediumImpact();
    if (!widget.resetOnUnlock || !mounted) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    if (_reduceMotion) {
      _progress.value = 0;
    } else {
      await _progress.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) {
      return;
    }
    setState(() => _unlocked = false);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.threshold > 0 && widget.threshold <= 1,
      'threshold must be in (0, 1]',
    );
    assert(widget.height > 0, 'height must be positive');
    assert(widget.thumbSize > 0, 'thumbSize must be positive');

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double thumbSize =
        widget.thumbSize.clamp(16.0, widget.height - 4).toDouble();
    final double inset = (widget.height - thumbSize) / 2;
    final TextStyle labelStyle = widget.labelStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        );
    final bool area = widget.highlight == FastShimmerSlideUnlockHighlight.area;
    // Label colors must be opaque. A translucent white base over white
    // glyphs cancels the beam (the mix stays white).
    // 文字扫光必须用不透明色。半透明白叠在白字形上会把光束抵消掉。
    final Color beamBase = widget.baseColor ??
        (area ? const Color(0xFF5C5C62) : const Color(0xFF8E8E93));
    final Color beamHighlight = widget.highlightColor ??
        (area ? const Color(0xFFD4D4DA) : Colors.white);
    final double beamWidth = area ? 0.38 : 0.3;

    Widget beam(Widget child) {
      return FastShimmerHighlight(
        duration: widget.duration,
        pauseDuration: widget.pauseDuration,
        bandWidth: beamWidth,
        baseColor: beamBase,
        highlightColor: beamHighlight,
        sheenRotation: area ? null : 0,
        child: child,
      );
    }

    Widget centeredLabel() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: thumbSize),
        child: Center(child: _buildLabel(labelStyle)),
      );
    }

    return Semantics(
      label: widget.label,
      hint: 'Slide to unlock',
      enabled: widget.enabled && !_unlocked,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double maxTravel =
              (width - inset * 2 - thumbSize).clamp(0.0, double.infinity);
          // Beam stays mounted across drag frames. The thumb is a transform,
          // same idea as FastSlidable's SlideTransition: pointer moves must
          // not rebuild the ShaderMask.
          // 光束在拖动帧之间保持挂载。滑钮只做 transform，和 FastSlidable 的
          // SlideTransition 一样：手指移动不要重建 ShaderMask。
          final Widget sheen = area
              ? beam(
                  SizedBox(
                    width: width,
                    height: widget.height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.trackColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: thumbSize),
                  child: Center(child: beam(_buildLabel(labelStyle))),
                );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: widget.enabled ? _onDragStart : null,
            onHorizontalDragUpdate: widget.enabled
                ? (DragUpdateDetails details) =>
                    _onDragUpdate(details, maxTravel, rtl)
                : null,
            onHorizontalDragEnd: widget.enabled ? _handleDragEnd : null,
            onHorizontalDragCancel: widget.enabled ? _handleDragCancel : null,
            child: SizedBox(
              width: width,
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (!area)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.trackColor ?? const Color(0xFF3A3A3C),
                          borderRadius:
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: _SheenGate(
                      holding: _holdSheen,
                      child: sheen,
                    ),
                  ),
                  if (area) Positioned.fill(child: centeredLabel()),
                  Positioned(
                    left: rtl ? null : inset,
                    right: rtl ? inset : null,
                    top: inset,
                    width: thumbSize,
                    height: thumbSize,
                    child: _SlidingThumb(
                      progress: _progress,
                      maxTravel: maxTravel,
                      rtl: rtl,
                      size: thumbSize,
                      color: widget.thumbColor,
                      icon: _unlocked
                          ? (widget.successIcon ?? Icons.check)
                          : (widget.thumbIcon ?? Icons.chevron_right),
                      flipX: rtl && !_unlocked,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Label stays fully opaque; only the string may swap after unlock.
  /// 文案始终不透明；解锁后最多换成成功文案。
  Widget _buildLabel(TextStyle style) {
    final String text = _unlocked && widget.successLabel != null
        ? widget.successLabel!
        : widget.label;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style.copyWith(color: Colors.white),
    );
  }
}

/// Freezes the beam ticker while a drag is active.
/// 拖动期间冻结光束 ticker。
class _SheenGate extends StatelessWidget {
  const _SheenGate({
    required this.holding,
    required this.child,
  });

  final ValueNotifier<bool> holding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: holding,
      builder: (BuildContext context, bool isHolding, Widget? child) {
        return TickerMode(enabled: !isHolding, child: child!);
      },
      child: child,
    );
  }
}

/// Thumb that follows [progress] with a paint-only transform.
/// 滑钮跟随 [progress]，只用绘制期 transform 移动。
class _SlidingThumb extends StatelessWidget {
  const _SlidingThumb({
    required this.progress,
    required this.maxTravel,
    required this.rtl,
    required this.size,
    required this.color,
    required this.icon,
    required this.flipX,
  });

  final Animation<double> progress;
  final double maxTravel;
  final bool rtl;
  final double size;
  final Color color;
  final IconData icon;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, Widget? child) {
        final double travel = maxTravel * progress.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(rtl ? -travel : travel, 0),
          child: child,
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: <Widget>[
            _ThumbDisc(size: size, color: color),
            _ThumbIcon(size: size, icon: icon, flipX: flipX),
          ],
        ),
      ),
    );
  }
}

/// Chevron / check drawn above the beam so the glyph stays readable.
/// 画在光束之上的箭头 / 对勾，保证图标仍然可读。
class _ThumbIcon extends StatelessWidget {
  const _ThumbIcon({
    required this.size,
    required this.icon,
    required this.flipX,
  });

  final double size;
  final IconData icon;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    final Widget glyph = Icon(
      icon,
      color: const Color(0xFF3A3A3C),
      size: size * 0.48,
    );
    return flipX ? Transform.flip(flipX: true, child: glyph) : glyph;
  }
}

/// Opaque disc drawn above the beam so the knob stays a solid affordance.
/// 画在光束之上的不透明圆盘，保证滑钮始终是可辨认的实体。
class _ThumbDisc extends StatelessWidget {
  const _ThumbDisc({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
