import 'package:flutter/material.dart';

import '../controller/fast_slidable_controller.dart';
import '../theme/fast_slidable_theme.dart';

/// Callback for a slidable action tap.
/// 滑动操作被点击时的回调。
typedef FastSlidableActionCallback = void Function(BuildContext context);

/// A custom action that fills its flex slot in a [FastSlidablePane].
/// 在 [FastSlidablePane] 中按 flex 占位的自定义操作。
class FastSlidableCustomAction extends StatelessWidget {
  /// Creates a custom action.
  /// 创建自定义操作。
  const FastSlidableCustomAction({
    super.key,
    this.flex = 1,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor,
    this.autoClose = true,
    this.borderRadius,
    this.padding,
    this.alignment,
    required this.onPressed,
    required this.child,
  }) : assert(flex > 0);

  /// Flex factor among sibling actions.
  /// 与同侧其他操作分配空间的 flex。
  final int flex;

  /// Button background.
  /// 按钮背景色。
  final Color backgroundColor;

  /// Icon / label color. Falls back to contrast or theme.
  /// 图标 / 文案色。未设时按对比度或主题回退。
  final Color? foregroundColor;

  /// Whether to close the pane after [onPressed].
  /// 点击后是否关闭操作区。
  final bool autoClose;

  /// Optional corner radius. Theme default when `null`.
  /// 可选圆角。为 `null` 时用主题。
  final BorderRadius? borderRadius;

  /// Optional inner padding.
  /// 可选内边距。
  final EdgeInsets? padding;

  /// Child alignment inside the button.
  /// 按钮内子组件对齐。
  final Alignment? alignment;

  /// Tap handler. `null` disables the button.
  /// 点击回调。为 `null` 时按钮不可用。
  final FastSlidableActionCallback? onPressed;

  /// Action content.
  /// 操作内容。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final FastSlidableTheme theme = FastSlidableTheme.resolve(context);
    final Color effectiveForeground = foregroundColor ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.light
            ? Colors.black
            : theme.actionForegroundColor);
    final BorderRadius radius = borderRadius ??
        BorderRadius.circular(theme.actionBorderRadius);

    return Expanded(
      flex: flex,
      child: SizedBox.expand(
        child: OutlinedButton(
          onPressed: onPressed == null ? null : () => _handleTap(context),
          style: OutlinedButton.styleFrom(
            padding: padding ?? EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: backgroundColor,
            disabledForegroundColor:
                effectiveForeground.withOpacity(0.38),
            foregroundColor: effectiveForeground,
            shape: RoundedRectangleBorder(borderRadius: radius),
            side: BorderSide.none,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: effectiveForeground),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: effectiveForeground),
              child: Align(
                alignment: alignment ?? Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    onPressed?.call(context);
    if (autoClose) {
      FastSlidableScope.maybeOf(context)?.controller.close();
    }
  }
}

/// An action with an optional icon and label.
/// 带可选图标与文案的操作。
class FastSlidableAction extends StatelessWidget {
  /// Creates an icon / label action.
  /// 创建图标 / 文案操作。
  ///
  /// At least one of [icon] or [label] must be set.
  /// [icon] 与 [label] 至少设置一个。
  const FastSlidableAction({
    super.key,
    this.flex = 1,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor,
    this.autoClose = true,
    required this.onPressed,
    this.icon,
    this.spacing,
    this.label,
    this.borderRadius,
    this.padding,
    this.alignment,
  })  : assert(flex > 0),
        assert(icon != null || label != null);

  /// Flex factor among sibling actions.
  /// 与同侧其他操作分配空间的 flex。
  final int flex;

  /// Button background.
  /// 按钮背景色。
  final Color backgroundColor;

  /// Icon / label color.
  /// 图标 / 文案色。
  final Color? foregroundColor;

  /// Whether to close the pane after [onPressed].
  /// 点击后是否关闭操作区。
  final bool autoClose;

  /// Tap handler.
  /// 点击回调。
  final FastSlidableActionCallback? onPressed;

  /// Optional icon.
  /// 可选图标。
  final IconData? icon;

  /// Gap between icon and label. Theme default when `null`.
  /// 图标与文案间距。为 `null` 时用主题。
  final double? spacing;

  /// Optional label.
  /// 可选文案。
  final String? label;

  /// Optional corner radius.
  /// 可选圆角。
  final BorderRadius? borderRadius;

  /// Optional inner padding.
  /// 可选内边距。
  final EdgeInsets? padding;

  /// Child alignment.
  /// 内容对齐。
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    final FastSlidableTheme theme = FastSlidableTheme.resolve(context);
    final double gap = spacing ?? theme.actionSpacing;
    final List<Widget> children = <Widget>[];

    if (icon != null) {
      children.add(Icon(icon));
    }
    if (label != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: gap));
      }
      children.add(
        Text(
          label!,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final Widget child = children.length == 1
        ? children.first
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final Widget item in children)
                Flexible(child: item),
            ],
          );

    return FastSlidableCustomAction(
      flex: flex,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      autoClose: autoClose,
      borderRadius: borderRadius,
      padding: padding,
      alignment: alignment,
      onPressed: onPressed,
      child: child,
    );
  }
}
