part of 'fast_refresh.dart';

/// FastRefresh 作用域内的 [ScrollBehavior]。
///
/// 注入自定义 [ScrollPhysics]，关闭平台默认越界指示器（发光 / 橡皮筋），
/// 并允许鼠标、触控板等指针设备拖拽，方便 Web / 桌面端调试。
class FastRefreshScrollBehavior extends ScrollBehavior {
  /// 允许参与拖拽的指针设备。默认包含全部 [PointerDeviceKind]。
  static final Set<PointerDeviceKind> _kDragDevices =
      PointerDeviceKind.values.toSet();

  /// 注入给子滚动视图的物理；为 `null` 时回退平台默认。
  final ScrollPhysics? _physics;

  /// 创建行为。
  ///
  /// [_physics] 一般传入 [_FRScrollPhysics]。
  const FastRefreshScrollBehavior([this._physics]);

  /// 优先使用注入的 [_physics]。
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  /// 不绘制 Glow / Stretch 等系统越界效果，避免与自定义指示器叠在一起。
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  /// 桌面端补系统滚动条；NestedScrollView 内层或多个 position 时跳过。
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        assert(details.controller != null);
        // NestedScrollView 内层或多个 position 时不套 Scrollbar，避免冲突。
        if (details.controller!.positions.length > 1 ||
            details.controller!.debugLabel == 'inner') {
          return child;
        }
        return Scrollbar(
          controller: details.controller,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
      // ignore: unreachable_switch_default
      default:
        return child;
    }
  }

  /// 允许全部指针设备拖拽，方便 Web / 桌面端调试。
  @override
  Set<PointerDeviceKind> get dragDevices => _kDragDevices;
}
