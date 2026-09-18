import 'package:example/pages/animated_list_example/animated_list_basic_example.dart';
import 'package:example/pages/animated_list_example/animated_list_drag_example.dart';
import 'package:example/pages/animated_list_example/animated_list_grid_example.dart';
import 'package:example/pages/animated_list_example/animated_list_programmatic_example.dart';
import 'package:example/pages/animated_list_example/animated_list_refresh_example.dart';
import 'package:example/pages/animated_list_example/animated_list_slidable_example.dart';
import 'package:flutter/material.dart';

/// FastAnimatedList / FastReorderableList / composite demos.
class AnimatedListExample extends StatelessWidget {
  const AnimatedListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List Example')),
      body: ListView(
        children: <Widget>[
          _tile(
            context,
            title: '增删动画',
            subtitle: 'FastAnimatedList：插入 / 删除 + 首屏错开',
            page: const AnimatedListBasicExample(),
          ),
          _tile(
            context,
            title: '网格',
            subtitle: 'FastAnimatedList.grid + stagger.grid',
            page: const AnimatedListGridExample(),
          ),
          _tile(
            context,
            title: '拖拽排序',
            subtitle: 'FastReorderableList：长按拖拽',
            page: const AnimatedListDragExample(),
          ),
          _tile(
            context,
            title: '组合 / 手柄',
            subtitle: 'FastAnimatedCompositeList + FastListDragHandle',
            page: const AnimatedListProgrammaticExample(),
          ),
          _tile(
            context,
            title: 'Refresh 组合',
            subtitle: 'FastRefresh.builder + sliver 组合列表',
            page: const AnimatedListRefreshExample(),
          ),
          _tile(
            context,
            title: 'Slidable 组合',
            subtitle: '水平滑动删除 + 手柄排序',
            page: const AnimatedListSlidableExample(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => page));
      },
    );
  }
}
