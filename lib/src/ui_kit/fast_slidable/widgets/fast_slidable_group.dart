import 'package:flutter/widgets.dart';

import '../../fast_refresh/fast_refresh.dart';
import '../controller/fast_slidable_controller.dart';

/// Keeps only one [FastSlidable] open per [FastSlidable.groupTag].
/// 同一 [FastSlidable.groupTag] 同时只打开一行。
class FastSlidableGroup extends StatefulWidget {
  /// Creates a group host.
  /// 创建组宿主。
  const FastSlidableGroup({
    super.key,
    this.closeWhenOpened = true,
    this.closeWhenTapped = true,
    required this.child,
  });

  /// Close others in the same tag when one opens.
  /// 打开一行时关闭同 tag 的其他行。
  final bool closeWhenOpened;

  /// Close the open row when another row in the group is tapped.
  /// 点同组另一行时关闭已打开的行。
  final bool closeWhenTapped;

  /// Subtree that contains [FastSlidable] widgets.
  /// 包含 [FastSlidable] 的子树。
  final Widget child;

  @override
  State<FastSlidableGroup> createState() => _FastSlidableGroupState();
}

class _FastSlidableGroupState extends State<FastSlidableGroup> {
  late final FastSlidableGroupHost host = FastSlidableGroupHost(
    closeWhenOpened: widget.closeWhenOpened,
    closeWhenTapped: widget.closeWhenTapped,
  );

  @override
  void didUpdateWidget(covariant FastSlidableGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    host
      ..closeWhenOpened = widget.closeWhenOpened
      ..closeWhenTapped = widget.closeWhenTapped;
  }

  @override
  void dispose() {
    host.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FastSlidableGroupScope(
      host: host,
      child: widget.child,
    );
  }
}

/// Registry used by [FastSlidable] widgets under a [FastSlidableGroup].
/// [FastSlidableGroup] 下各 [FastSlidable] 使用的注册表。
class FastSlidableGroupHost {
  /// Creates a host.
  /// 创建宿主。
  FastSlidableGroupHost({
    required this.closeWhenOpened,
    required this.closeWhenTapped,
  });

  /// See [FastSlidableGroup.closeWhenOpened].
  bool closeWhenOpened;

  /// See [FastSlidableGroup.closeWhenTapped].
  bool closeWhenTapped;

  /// Bumps when open membership changes so barriers can rebuild.
  /// 打开集合变化时自增，供遮罩重建。
  final ValueNotifier<int> version = ValueNotifier<int>(0);

  final Map<Object?, Set<FastSlidableController>> _members =
      <Object?, Set<FastSlidableController>>{};
  final Set<FastSlidableController> _open = <FastSlidableController>{};

  /// Registers [controller] under [tag].
  /// 将 [controller] 登记到 [tag]。
  void register(Object? tag, FastSlidableController controller) {
    _members.putIfAbsent(tag, () => <FastSlidableController>{}).add(controller);
  }

  /// Unregisters [controller].
  /// 取消登记 [controller]。
  void unregister(Object? tag, FastSlidableController controller) {
    _members[tag]?.remove(controller);
    _open.remove(controller);
  }

  /// Marks [controller] as opening and closes others when configured.
  /// 标记 [controller] 正在打开，并按配置关闭其他行。
  void handleOpening(Object? tag, FastSlidableController controller) {
    final bool added = _open.add(controller);
    if (closeWhenOpened) {
      final Set<FastSlidableController>? others = _members[tag];
      if (others != null) {
        for (final FastSlidableController other in List<FastSlidableController>.of(
          others,
        )) {
          if (other != controller && !other.closing) {
            other.close();
          }
        }
      }
    }
    if (added) {
      version.value += 1;
    }
  }

  /// Marks [controller] as closed.
  /// 标记 [controller] 已关闭。
  void handleClosed(FastSlidableController controller) {
    if (_open.remove(controller)) {
      version.value += 1;
    }
  }

  /// Whether another open row should swallow taps on [controller]'s child.
  /// 是否有其他已打开行，从而吞掉 [controller] 内容上的点击。
  bool shouldAbsorb(Object? tag, FastSlidableController controller) {
    if (!closeWhenTapped) {
      return false;
    }
    final Set<FastSlidableController>? others = _members[tag];
    if (others == null) {
      return false;
    }
    for (final FastSlidableController other in others) {
      if (other != controller &&
          !other.closing &&
          other.ratio.abs() > 0.01) {
        return true;
      }
    }
    return false;
  }

  /// Closes every open controller in [tag].
  /// 关闭 [tag] 下所有已打开的控制器。
  void closeTag(Object? tag) {
    final Set<FastSlidableController>? members = _members[tag];
    if (members == null) {
      return;
    }
    for (final FastSlidableController controller
        in List<FastSlidableController>.of(members)) {
      if (!controller.closing && controller.ratio.abs() > 0) {
        controller.close();
      }
    }
  }

  /// Releases notifiers.
  /// 释放通知器。
  void dispose() {
    version.dispose();
  }
}

class _FastSlidableGroupScope extends InheritedWidget {
  const _FastSlidableGroupScope({
    required this.host,
    required super.child,
  });

  final FastSlidableGroupHost host;

  @override
  bool updateShouldNotify(_FastSlidableGroupScope oldWidget) {
    return host != oldWidget.host;
  }
}

/// Registers a [FastSlidable] with the nearest group and tap barrier.
/// 向最近的组登记，并处理点击关闭。
class FastSlidableGroupInteractor extends StatefulWidget {
  /// Creates an interactor.
  /// 创建交互器。
  const FastSlidableGroupInteractor({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

  /// Shared group tag.
  /// 共享组标记。
  final Object? groupTag;

  /// Row controller.
  /// 行控制器。
  final FastSlidableController controller;

  /// Child content.
  /// 行内容。
  final Widget child;

  @override
  State<FastSlidableGroupInteractor> createState() =>
      _FastSlidableGroupInteractorState();
}

class _FastSlidableGroupInteractorState
    extends State<FastSlidableGroupInteractor> {
  FastSlidableGroupHost? _host;

  @override
  void initState() {
    super.initState();
    widget.controller.animation.addStatusListener(_handleStatus);
    widget.controller.animation.addListener(_handleValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FastSlidableGroupHost? next = context
        .dependOnInheritedWidgetOfExactType<_FastSlidableGroupScope>()
        ?.host;
    if (next != _host) {
      _host?.unregister(widget.groupTag, widget.controller);
      _host = next;
      _host?.register(widget.groupTag, widget.controller);
    }
  }

  @override
  void didUpdateWidget(covariant FastSlidableGroupInteractor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.animation.removeStatusListener(_handleStatus);
      oldWidget.controller.animation.removeListener(_handleValue);
      _host?.unregister(oldWidget.groupTag, oldWidget.controller);
      widget.controller.animation.addStatusListener(_handleStatus);
      widget.controller.animation.addListener(_handleValue);
      _host?.register(widget.groupTag, widget.controller);
    } else if (oldWidget.groupTag != widget.groupTag) {
      _host?.unregister(oldWidget.groupTag, widget.controller);
      _host?.register(widget.groupTag, widget.controller);
    }
  }

  @override
  void dispose() {
    widget.controller.animation.removeStatusListener(_handleStatus);
    widget.controller.animation.removeListener(_handleValue);
    _host?.unregister(widget.groupTag, widget.controller);
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    final bool moving = status == AnimationStatus.forward ||
        status == AnimationStatus.reverse;
    if (moving && !widget.controller.closing) {
      _host?.handleOpening(widget.groupTag, widget.controller);
    }
    if (status == AnimationStatus.dismissed) {
      _host?.handleClosed(widget.controller);
    }
  }

  void _handleValue() {
    if (widget.controller.animation.value == 0) {
      _host?.handleClosed(widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FastSlidableGroupHost? host = _host;
    if (host == null) {
      return widget.child;
    }
    return ValueListenableBuilder<int>(
      valueListenable: host.version,
      builder: (BuildContext context, int _, Widget? child) {
        final bool absorb = host.shouldAbsorb(widget.groupTag, widget.controller);
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: absorb ? () => host.closeTag(widget.groupTag) : null,
          child: AbsorbPointer(
            absorbing: absorb,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Closes the pane when the nearest [Scrollable] starts scrolling.
/// 最近的 [Scrollable] 开始滚动时关闭操作区。
class FastSlidableScrollCloser extends StatefulWidget {
  /// Creates a scroll closer.
  /// 创建滚动关闭器。
  const FastSlidableScrollCloser({
    super.key,
    required this.controller,
    required this.closeOnScroll,
    required this.child,
  });

  /// Row controller.
  /// 行控制器。
  final FastSlidableController controller;

  /// Whether scrolling should close the pane.
  /// 滚动是否关闭操作区。
  final bool closeOnScroll;

  /// Child.
  /// 子组件。
  final Widget child;

  @override
  State<FastSlidableScrollCloser> createState() =>
      _FastSlidableScrollCloserState();
}

class _FastSlidableScrollCloserState extends State<FastSlidableScrollCloser> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detach();
    _attach();
  }

  @override
  void didUpdateWidget(covariant FastSlidableScrollCloser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.closeOnScroll != widget.closeOnScroll ||
        oldWidget.controller != widget.controller) {
      _detach();
      _attach();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _attach() {
    if (!widget.closeOnScroll) {
      return;
    }
    _position = Scrollable.maybeOf(context)?.position;
    _position?.isScrollingNotifier.addListener(_handleScrolling);
  }

  void _detach() {
    _position?.isScrollingNotifier.removeListener(_handleScrolling);
    _position = null;
  }

  void _handleScrolling() {
    if (widget.closeOnScroll &&
        _position != null &&
        _position!.isScrollingNotifier.value) {
      widget.controller.close();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Closes the row while an ancestor [FastRefresh] is pulling or processing.
/// 祖先 [FastRefresh] 正在下拉或处理任务时关掉当前行。
///
/// Does not [State.setState] on finger-down. Gesture widgets stay mounted;
/// [_FastSlidableGesture] reads [isActive] when a swipe starts.
/// 手指按下不要 [State.setState]，手势层保持挂载；起滑时再读 [isActive]。
class FastSlidableRefreshLock extends StatefulWidget {
  /// Creates a refresh lock.
  /// 创建刷新锁。
  const FastSlidableRefreshLock({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Row controller closed when refresh becomes active.
  /// 刷新激活时会关闭的行控制器。
  final FastSlidableController controller;

  /// Locked row.
  /// 被锁的行。
  final Widget child;

  /// Whether the nearest lock is currently blocking a swipe.
  /// 最近的锁是否正在挡住滑动。
  static bool isActive(BuildContext context) {
    final _FastSlidableRefreshLockState? state =
        context.findAncestorStateOfType<_FastSlidableRefreshLockState>();
    return state?.isActive ?? false;
  }

  @override
  State<FastSlidableRefreshLock> createState() =>
      _FastSlidableRefreshLockState();
}

class _FastSlidableRefreshLockState extends State<FastSlidableRefreshLock> {
  FastRefreshData? _data;
  bool _locked = false;

  /// Live refresh / load / finger-down session. Not a build input.
  /// 当前刷新 / 加载 / 按住会话。不作为 build 输入。
  bool get isActive {
    final FastRefreshData? data = _data;
    if (data == null) {
      return false;
    }
    return data.userOffsetNotifier.value ||
        data.headerNotifier.mode != FastRefreshMode.inactive ||
        data.footerNotifier.mode != FastRefreshMode.inactive;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unbind();
    _data = FastRefresh.maybeOf(context);
    _bind();
    _closeIfActive();
  }

  @override
  void dispose() {
    _unbind();
    super.dispose();
  }

  void _bind() {
    _data?.userOffsetNotifier.addListener(_closeIfActive);
    _data?.headerNotifier.addModeChangeListener(_onMode);
    _data?.footerNotifier.addModeChangeListener(_onMode);
  }

  void _unbind() {
    _data?.userOffsetNotifier.removeListener(_closeIfActive);
    _data?.headerNotifier.removeModeChangeListener(_onMode);
    _data?.footerNotifier.removeModeChangeListener(_onMode);
    _data = null;
  }

  void _onMode(FastRefreshMode mode, double offset) {
    _closeIfActive();
  }

  void _closeIfActive() {
    final bool next = isActive;
    if (next && !_locked) {
      widget.controller.close();
    }
    _locked = next;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
