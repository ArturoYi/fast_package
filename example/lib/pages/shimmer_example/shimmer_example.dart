import 'package:example/pages/shimmer_example/highlight/shimmer_highlight_example.dart';
import 'package:example/pages/shimmer_example/skeleton/shimmer_skeleton_example.dart';
import 'package:example/pages/shimmer_example/slide_hint/shimmer_slide_hint_example.dart';
import 'package:flutter/material.dart';

/// Shimmer 演示入口：骨架屏、扫光文字、滑动解锁。
class ShimmerExample extends StatelessWidget {
  const ShimmerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer Example')),
      body: ListView(
        children: <Widget>[
          _tile(
            context,
            title: '骨架屏',
            subtitle: 'FastShimmer：手写 skeleton 与真实内容切换',
            page: const ShimmerSkeletonExample(),
          ),
          _tile(
            context,
            title: '扫光文字',
            subtitle: 'FastShimmerHighlight：真实字形 / 图标上的细高光带',
            page: const ShimmerHighlightExample(),
          ),
          _tile(
            context,
            title: '滑动解锁',
            subtitle: '整条区域 / 仅文字，同一套 3 秒扫过 + 1.8 秒停顿',
            page: const ShimmerSlideHintExample(),
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
