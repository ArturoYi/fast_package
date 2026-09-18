/// FastAnimatedList / FastReorderableList / FastAnimatedCompositeList.
///
/// 仅依赖 Flutter SDK。增删与拖拽拆成两个入口，组合入口共用同一套核心。
/// 首屏错开用共享 ticker；超过 animationBudget 的大改动整表对齐。
library;

export 'animation/fast_animated_list_transition.dart'
    show FastListEntrance, FastListStaggerSlot, FastStagger;
export 'animation/fast_list_stagger.dart'
    show FastListStagger, FastListStaggerKind, FastStaggerScope;
export 'controller/fast_animated_composite_list_controller.dart';
export 'drag/fast_list_drag_coordinator.dart'
    show FastListDragHandle, FastListDragTrigger, FastListItemDragScope;
export 'theme/fast_animated_composite_list_theme.dart';
export 'widgets/fast_animated_composite_core.dart'
    show
        FastListItemBuilder,
        FastListItemId,
        FastListProxyBuilder,
        FastListTransitionBuilder;
export 'widgets/fast_animated_composite_list.dart';
export 'widgets/fast_animated_list.dart'
    show FastAnimatedList, FastSliverAnimatedList;
export 'widgets/fast_reorderable_list.dart';
