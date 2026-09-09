import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// refreshOnStart 演示：首帧自动刷新一次，结束后仍可手动 [callRefresh]。
///
/// AppBar 在 [FastRefresh] 外面，自动刷新从列表顶开始。
class RefreshOnStartExample extends StatefulWidget {
  const RefreshOnStartExample({super.key});

  @override
  State<RefreshOnStartExample> createState() => _RefreshOnStartExampleState();
}

class _RefreshOnStartExampleState extends State<RefreshOnStartExample> {
  final FastRefreshController _controller = FastRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController _scrollController = ScrollController();

  List<String> _items = <String>[];
  int _page = 0;
  int _autoRefreshCount = 0;

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
      if (_page == 0) {
        _autoRefreshCount += 1;
      }
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
        title: const Text('Refresh · Start'),
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
        refreshOnStart: true,
        header: const FastClassicHeader(
          dragText: '下拉刷新',
          armedText: '释放刷新',
          readyText: '正在刷新...',
          processingText: '正在刷新...',
          processedText: '刷新成功',
          failedText: '刷新失败',
          messageText: '上次更新 %T',
        ),
        footer: const FastClassicFooter(
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
          itemCount: _items.isEmpty ? 1 : _items.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            if (_items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'refreshOnStart: true，进入页后自动刷新一次。'
                  '结束后点右上角仍可再刷。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '已自动刷新 $_autoRefreshCount 次。右上角可再 callRefresh。',
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
