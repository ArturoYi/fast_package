import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Material 薄皮肤：Header 用系统月牙转圈（clamping），Footer 仍可触底加载。
class RefreshMaterialExample extends StatefulWidget {
  const RefreshMaterialExample({super.key});

  @override
  State<RefreshMaterialExample> createState() => _RefreshMaterialExampleState();
}

class _RefreshMaterialExampleState extends State<RefreshMaterialExample> {
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
        title: const Text('Refresh · Material'),
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
        header: const FastMaterialHeader(),
        footer: const FastMaterialFooter(),
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
                  'FastMaterialHeader：clamping + RefreshProgressIndicator。'
                  'FastMaterialFooter：触底 70px 自动加载，手势与 Classic Footer 相同。',
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
