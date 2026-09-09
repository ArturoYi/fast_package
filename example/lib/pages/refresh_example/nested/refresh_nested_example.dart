import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Nested 演示：外层钉 [SliverAppBar]，[FastRefresh.builder] 只包内层列表。
///
/// [isNested] 为 `true`，physics 挂到内层 [ListView]。
/// 刷新发生在钉住顶栏下方，而不是屏幕顶。
class RefreshNestedExample extends StatefulWidget {
  const RefreshNestedExample({super.key});

  @override
  State<RefreshNestedExample> createState() => _RefreshNestedExampleState();
}

class _RefreshNestedExampleState extends State<RefreshNestedExample> {
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: 120,
              title: const Text('Refresh · Nested'),
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
          ];
        },
        body: FastRefresh.builder(
          controller: _controller,
          scrollController: _scrollController,
          isNested: true,
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
          childBuilder: (BuildContext context, ScrollPhysics physics) {
            return CustomScrollView(
              physics: physics,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'isNested: true，physics 挂在内层列表。'
                      '钉住的 AppBar 在 FastRefresh 外面，刷新从列表顶开始。',
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
              ],
            );
          },
        ),
      ),
    );
  }
}
