import 'package:example/pages/refresh_example/builder/refresh_builder_example.dart';
import 'package:example/pages/refresh_example/widget/refresh_widget_example.dart';
import 'package:flutter/material.dart';

/// Refresh 演示入口：Widget 构造与 builder 构造分目录对照。
class RefreshExample extends StatelessWidget {
  const RefreshExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh Example')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Widget 构造'),
            subtitle: const Text('FastRefresh(child)：physics 自动注入，适合单列表'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RefreshWidgetExample(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Builder 构造'),
            subtitle: const Text(
              'FastRefresh.builder：自己挂 physics，适合 CustomScrollView / 嵌套滚动',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RefreshBuilderExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
