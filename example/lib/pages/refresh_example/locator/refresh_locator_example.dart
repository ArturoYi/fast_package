import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Locator 演示：指示器放进 sliver 列表，而不是 FastRefresh 顶边的 Stack。
///
/// Header / Footer 的 [position] 为 locator，必须插入
/// [FastHeaderLocator.sliver] / [FastFooterLocator.sliver]。
class RefreshLocatorExample extends StatefulWidget {
  const RefreshLocatorExample({super.key});

  @override
  State<RefreshLocatorExample> createState() => _RefreshLocatorExampleState();
}

class _RefreshLocatorExampleState extends State<RefreshLocatorExample> {
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
        title: const Text('Refresh · Locator'),
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
      body: FastRefresh.builder(
        controller: _controller,
        scrollController: _scrollController,
        header: const FastClassicHeader(
          position: FastRefreshIndicatorPosition.locator,
          dragText: '下拉刷新',
          armedText: '释放刷新',
          readyText: '正在刷新...',
          processingText: '正在刷新...',
          processedText: '刷新成功',
          failedText: '刷新失败',
          messageText: '上次更新 %T',
        ),
        footer: const FastClassicFooter(
          position: FastRefreshIndicatorPosition.locator,
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
        childBuilder: (BuildContext context, ScrollPhysics physics) {
          return CustomScrollView(
            controller: _scrollController,
            physics: physics,
            slivers: <Widget>[
              const FastHeaderLocator.sliver(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '指示器在 sliver 里，跟着列表走，不是屏幕顶的 Stack 叠层。'
                    '漏写 Locator 时 position: locator 无法绘制。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(_items[index]),
                          subtitle: Text('page $_page'),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                  childCount: _items.length,
                ),
              ),
              const FastFooterLocator.sliver(),
            ],
          );
        },
      ),
    );
  }
}
