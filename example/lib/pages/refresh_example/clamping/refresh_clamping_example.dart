import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// clamping 演示：列表停在边缘，只有指示器移动。
///
/// AppBar 在 [FastRefresh] 外面。Footer 关闭 [infiniteOffset]，
/// 因为 clamping 不能和无限加载同时开。
class RefreshClampingExample extends StatefulWidget {
  const RefreshClampingExample({super.key});

  @override
  State<RefreshClampingExample> createState() => _RefreshClampingExampleState();
}

class _RefreshClampingExampleState extends State<RefreshClampingExample> {
  final FastRefreshController _controller = FastRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController _scrollController = ScrollController();

  List<String> _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');
  int _page = 1;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    setState(() {
      _page = 1;
      _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');
    });
    _controller
      ..finishRefresh()
      ..resetFooter();
  }

  Future<void> _onLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    if (_page >= 3) {
      _controller.finishLoad(FastRefreshResult.noMore);
      return;
    }
    setState(() {
      _page += 1;
      final int start = _items.length;
      _items = <String>[
        ..._items,
        ...List<String>.generate(10, (int i) => 'Item ${start + i + 1}'),
      ];
    });
    _controller.finishLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh · Clamping'),
        actions: <Widget>[
          IconButton(
            tooltip: 'callRefresh',
            onPressed: () => _controller.callRefresh(
              scrollController: _scrollController,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FastRefresh(
        controller: _controller,
        scrollController: _scrollController,
        header: const FastClassicHeader(
          clamping: true,
          dragText: '下拉刷新',
          armedText: '释放刷新',
          readyText: '正在刷新...',
          processingText: '正在刷新...',
          processedText: '刷新成功',
          failedText: '刷新失败',
          messageText: '上次更新 %T',
        ),
        footer: const FastClassicFooter(
          clamping: true,
          infiniteOffset: null,
          dragText: '上拉加载',
          armedText: '释放加载',
          readyText: '正在加载...',
          processingText: '正在加载...',
          processedText: '加载成功',
          noMoreText: '没有更多了',
          failedText: '加载失败',
          messageText: '上次更新 %T',
        ),
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        child: ListView.separated(
          controller: _scrollController,
          itemCount: _items.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'clamping: true，列表不跟着越界，只有指示器移动。'
                  'Footer 已关掉 infiniteOffset（与 clamping 互斥），需上拉过阈值再松手。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return ListTile(
              title: Text(_items[index - 1]),
              subtitle: Text('page $_page'),
            );
          },
        ),
      ),
    );
  }
}
