import 'package:example/pages/refresh_example/builder/refresh_builder_example.dart';
import 'package:example/pages/refresh_example/clamping/refresh_clamping_example.dart';
import 'package:example/pages/refresh_example/horizontal/refresh_horizontal_example.dart';
import 'package:example/pages/refresh_example/locator/refresh_locator_example.dart';
import 'package:example/pages/refresh_example/nested/refresh_nested_example.dart';
import 'package:example/pages/refresh_example/refresh_on_start/refresh_on_start_example.dart';
import 'package:example/pages/refresh_example/secondary/refresh_secondary_example.dart';
import 'package:example/pages/refresh_example/widget/refresh_widget_example.dart';
import 'package:flutter/material.dart';

/// Refresh 演示入口：八页场景对照。
class RefreshExample extends StatelessWidget {
  const RefreshExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh Example')),
      body: ListView(
        children: <Widget>[
          _tile(
            context,
            title: 'Widget 构造',
            subtitle: 'FastRefresh(child)：physics 自动注入，适合单列表',
            page: const RefreshWidgetExample(),
          ),
          _tile(
            context,
            title: 'Builder 构造',
            subtitle: 'FastRefresh.builder：自己挂 physics，AppBar 在外',
            page: const RefreshBuilderExample(),
          ),
          _tile(
            context,
            title: 'Nested',
            subtitle: 'NestedScrollView + isNested：钉住顶栏，刷新在内层列表',
            page: const RefreshNestedExample(),
          ),
          _tile(
            context,
            title: 'Locator',
            subtitle: '指示器放进 sliver，跟着列表走',
            page: const RefreshLocatorExample(),
          ),
          _tile(
            context,
            title: 'refreshOnStart',
            subtitle: '进入页自动刷新一次，之后仍可手动刷新',
            page: const RefreshOnStartExample(),
          ),
          _tile(
            context,
            title: 'clamping',
            subtitle: '列表不越界，只有指示器移动',
            page: const RefreshClampingExample(),
          ),
          _tile(
            context,
            title: '横向',
            subtitle: '横向 ListView，可切 PageView；翻页不自动加载',
            page: const RefreshHorizontalExample(),
          ),
          _tile(
            context,
            title: '二楼',
            subtitle: '继续下拉打开二楼，返回键或按钮关闭',
            page: const RefreshSecondaryExample(),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => page),
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
