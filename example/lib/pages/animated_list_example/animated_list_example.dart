import 'package:example/pages/animated_list_example/animated_list_composite_example.dart';
import 'package:example/pages/animated_list_example/animated_list_drag_example.dart';
import 'package:example/pages/animated_list_example/animated_list_mutations_example.dart';
import 'package:example/pages/animated_list_example/animated_list_refresh_example.dart';
import 'package:example/pages/animated_list_example/animated_list_refresh_slidable_example.dart';
import 'package:example/pages/animated_list_example/animated_list_slidable_example.dart';
import 'package:flutter/material.dart';

/// FastAnimatedList / FastReorderableList / FastAnimatedReorderableList demos.
class AnimatedListExample extends StatelessWidget {
  const AnimatedListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          const _SectionLabel(text: '能力'),
          const _SceneCard(
            icon: Icons.playlist_add_outlined,
            color: Color(0xFF2563EB),
            title: '增删 / 批量增删',
            subtitle: '插入、删除、一次加 5 条 / 删 3 条，看错开入场',
            page: AnimatedListMutationsExample(),
          ),
          const _SceneCard(
            icon: Icons.drag_indicator,
            color: Color(0xFF7C3AED),
            title: '拖拽排序',
            subtitle: '长按整行或手柄拖拽；不改编数量',
            page: AnimatedListDragExample(),
          ),
          const _SceneCard(
            icon: Icons.swap_vert,
            color: Color(0xFF0F766E),
            title: '增删 + 拖拽',
            subtitle: 'FastAnimatedReorderableList，手柄与增删一起用',
            page: AnimatedListCompositeExample(),
          ),
          const SizedBox(height: 8),
          const _SectionLabel(text: '组合'),
          const _SceneCard(
            icon: Icons.refresh,
            color: Color(0xFFB45309),
            title: '配合 Refresh',
            subtitle: '下拉整表对齐，上拉批量插入并错开',
            page: AnimatedListRefreshExample(),
          ),
          const _SceneCard(
            icon: Icons.swipe_outlined,
            color: Color(0xFFDB2777),
            title: '配合 Slidable',
            subtitle: '左滑归档、右滑删除，手柄排序',
            page: AnimatedListSlidableExample(),
          ),
          const _SceneCard(
            icon: Icons.layers_outlined,
            color: Color(0xFF4338CA),
            title: 'Refresh + Slidable',
            subtitle: '刷新、滑动、增删、拖拽叠在同一条列表上',
            page: AnimatedListRefreshSlidableExample(),
          ),
          const SizedBox(height: 16),
          Text(
            '每个场景都可以切换 List / Sliver / Column，以及列表 / 网格。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.page,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
