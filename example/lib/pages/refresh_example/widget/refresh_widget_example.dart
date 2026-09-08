import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Widget 构造演示：[FastRefresh] 把 physics 注入 [child] 作用域。
///
/// [ListView] 不必写 `physics`。适合单个滚动视图。
class RefreshWidgetExample extends StatefulWidget {
  const RefreshWidgetExample({super.key});

  @override
  State<RefreshWidgetExample> createState() => _RefreshWidgetExampleState();
}

class _RefreshWidgetExampleState extends State<RefreshWidgetExample> {
  final FastRefreshController _controller = FastRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController _scrollController = ScrollController();

  List<String> _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');
  int _page = 1;
  bool _failNextRefresh = false;

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
    if (_failNextRefresh) {
      _failNextRefresh = false;
      _controller.finishRefresh(FastRefreshResult.fail);
      showToast('刷新失败');
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
        title: const Text('Refresh · Widget'),
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
      body: Column(
        children: <Widget>[
          SwitchListTile(
            title: const Text('下一次刷新失败'),
            value: _failNextRefresh,
            onChanged: (bool value) {
              setState(() => _failNextRefresh = value);
            },
          ),
          Expanded(
            child: FastRefresh(
              controller: _controller,
              scrollController: _scrollController,
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
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_items[index]),
                    subtitle: Text('page $_page'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
