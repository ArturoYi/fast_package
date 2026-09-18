/// FastSlidable：列表项滑动露出操作、满滑删除、程序化开关。
///
/// 仅依赖 Flutter SDK。与竖直 [FastRefresh] 组合时，刷新下拉 / 处理中会锁住手势。
/// 第一版不提供旧通知 / 0.6 迁移层。
library;

export 'controller/fast_slidable_controller.dart'
    show
        FastSlidableController,
        FastSlidableEndGesture,
        FastSlidableGestureKind,
        FastSlidableOpeningGesture,
        FastSlidableClosingGesture,
        FastSlidableStillGesture,
        FastSlidablePaneType,
        FastSlidableResizeRequest,
        FastSlidableScope,
        kFastSlidableExtentRatio;
export 'motion/fast_slidable_motion.dart'
    show FastSlidableMotion, FastSlidableMotionBuilder;
export 'theme/fast_slidable_theme.dart';
export 'widgets/fast_slidable_action.dart';
export 'widgets/fast_slidable_dismiss.dart'
    show FastSlidableDismiss, FastSlidableFullSwipe;
export 'widgets/fast_slidable_group.dart' show FastSlidableGroup;
export 'widgets/fast_slidable_pane.dart'
    show FastSlidablePane, FastSlidablePaneData;
export 'widgets/fast_slidable_widget.dart';
