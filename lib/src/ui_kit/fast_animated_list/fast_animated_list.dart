/// FastAnimatedList / FastReorderableList / FastAnimatedReorderableList.
///
/// 仅依赖 Flutter SDK。增删与拖拽拆成两个入口，两者都要时用 FastAnimatedReorderableList。
/// 首屏错开用列表共用的 AnimationController；超过 animationBudget 的大改动整表立刻到位。
library;

export 'animation/fast_animated_list_transition.dart'
    show FastListEntrance, FastListStaggerSlot, FastStagger;
export 'animation/fast_list_stagger.dart'
    show FastListStagger, FastListStaggerKind, FastStaggerScope;
export 'controller/fast_animated_list_controller.dart';
export 'drag/fast_list_drag_coordinator.dart'
    show FastListDragHandle, FastListDragTrigger, FastListItemDragScope;
export 'theme/fast_animated_list_theme.dart';
export 'widgets/fast_list_core.dart'
    show
        FastListItemBuilder,
        FastListItemId,
        FastListProxyBuilder,
        FastListTransitionBuilder;
export 'widgets/fast_animated_reorderable_list.dart';
export 'widgets/fast_animated_list.dart'
    show FastAnimatedList, FastSliverAnimatedList;
export 'widgets/fast_reorderable_list.dart';
