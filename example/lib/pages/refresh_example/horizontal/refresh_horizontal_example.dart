import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// 横向演示：`ListView` / `PageView` 的 `scrollDirection` 为 horizontal。
///
/// AppBar 在 [FastRefresh] 外面。[PageView] 时 Footer 关闭无限加载，
/// 避免翻页就触发 `onLoad`。
class RefreshHorizontalExample extends StatefulWidget {
  const RefreshHorizontalExample({super.key});

  @override
  State<RefreshHorizontalExample> createState() =>
      _RefreshHorizontalExampleState();
}

class _RefreshHorizontalExampleState extends State<RefreshHorizontalExample> {
  final FastRefreshController _controller = FastRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  List<String> _items = List<String>.generate(12, (int i) => 'Item ${i + 1}');
  int _page = 1;
  bool _usePageView = false;

  ScrollController get _activeController =>
      _usePageView ? _pageController : _scrollController;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    setState(() {
      _page = 1;
      _items = List<String>.generate(12, (int i) => 'Item ${i + 1}');
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
        ...List<String>.generate(6, (int i) => 'Item ${start + i + 1}'),
      ];
    });
    _controller.finishLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_usePageView ? 'Refresh · PageView' : 'Refresh · 横向'),
        actions: <Widget>[
          IconButton(
            tooltip: _usePageView ? '切换 ListView' : '切换 PageView',
            onPressed: () {
              setState(() => _usePageView = !_usePageView);
            },
            icon: Icon(
              _usePageView ? Icons.view_week_outlined : Icons.view_carousel_outlined,
            ),
          ),
          IconButton(
            tooltip: 'callRefresh',
            onPressed: () => _controller.callRefresh(
              scrollController: _activeController,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FastRefresh(
        clipBehavior: Clip.none,
        controller: _controller,
        scrollController: _activeController,
        header: const FastClassicHeader(
          dragText: '右拉刷新',
          armedText: '释放刷新',
          readyText: '正在刷新...',
          processingText: '正在刷新...',
          processedText: '刷新成功',
          failedText: '刷新失败',
          messageText: '上次更新 %T',
        ),
        footer: FastClassicFooter(
          infiniteOffset: _usePageView ? null : 70,
          dragText: '左拉加载',
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
        child: _usePageView ? _buildPageView() : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
          width: 220,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Center(
              child: ListTile(
                title: Text(_items[index]),
                subtitle: Text('page $_page'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _items[index],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('page $_page · 翻页不会自动加载'),
              ],
            ),
          ),
        );
      },
    );
  }
}
