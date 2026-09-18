import 'package:example/pages/slidable_example/slidable_basic_example.dart';
import 'package:example/pages/slidable_example/slidable_dismiss_example.dart';
import 'package:example/pages/slidable_example/slidable_programmatic_example.dart';
import 'package:example/pages/slidable_example/slidable_refresh_example.dart';
import 'package:example/pages/slidable_example/slidable_vertical_example.dart';
import 'package:flutter/material.dart';

/// FastSlidable 演示入口。
class SlidableExample extends StatelessWidget {
  const SlidableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slidable Example')),
      body: ListView(
        children: <Widget>[
          _tile(
            context,
            title: '基础与 Motion',
            subtitle: '左右滑出按钮；Behind / Drawer / Scroll / Stretch',
            page: const SlidableBasicExample(),
          ),
          _tile(
            context,
            title: '删除与满滑',
            subtitle: '一滑删除；继续滑到底触发主操作',
            page: const SlidableDismissExample(),
          ),
          _tile(
            context,
            title: '程序化开关',
            subtitle: 'FastSlidableController.openEnd / close',
            page: const SlidableProgrammaticExample(),
          ),
          _tile(
            context,
            title: '竖直滑动',
            subtitle: 'direction: Axis.vertical',
            page: const SlidableVerticalExample(),
          ),
          _tile(
            context,
            title: 'Refresh 组合',
            subtitle: 'FastPagingList + 水平 FastSlidable；刷新中锁模',
            page: const SlidableRefreshExample(),
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
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => page),
        );
      },
    );
  }
}
