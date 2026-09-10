import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// 分页演示：用 [FastPaging] 接管刷新 / 加载生命周期。
///
/// 对照 EasyRefresh 的 `easy_paging` 示例：子类只写 `onRefresh` / `onLoad`
/// 和页码字段，`noMore`、空态、refreshOnStart 占位由基类接到 FastRefresh。
class RefreshPagingExample extends StatefulWidget {
  const RefreshPagingExample({super.key});

  @override
  State<RefreshPagingExample> createState() => _RefreshPagingExampleState();
}

class _RefreshPagingExampleState extends State<RefreshPagingExample> {
  final FastRefreshController _controller = FastRefreshController();
  final ScrollController _scrollController = ScrollController();

  bool _forceEmpty = false;
  bool _useDefaultPhysics = false;
  bool _usePagingList = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh · Paging'),
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
            title: const Text('下一次刷新为空'),
            subtitle: const Text('演示 FastPaging 的 emptyWidget'),
            value: _forceEmpty,
            onChanged: (bool value) {
              setState(() => _forceEmpty = value);
            },
          ),
          SwitchListTile(
            title: const Text('Widget 构造'),
            subtitle: const Text('useDefaultPhysics：改用 FastRefresh(child)'),
            value: _useDefaultPhysics,
            onChanged: (bool value) {
              setState(() => _useDefaultPhysics = value);
            },
          ),
          SwitchListTile(
            title: const Text('FastPagingList'),
            subtitle: const Text('fetchPage + itemBuilder，不必写子类'),
            value: _usePagingList,
            onChanged: (bool value) {
              setState(() => _usePagingList = value);
            },
          ),
          Expanded(
            child: _usePagingList
                ? FastPagingList<String>(
                    key: ValueKey<String>(
                      'list-$_useDefaultPhysics-$_forceEmpty',
                    ),
                    controller: _controller,
                    scrollController: _scrollController,
                    useDefaultPhysics: _useDefaultPhysics,
                    refreshOnStart: true,
                    fetchPage: (int page) => _demoFetchPage(
                      page: page,
                      forceEmpty: _forceEmpty,
                    ),
                    emptyWidgetBuilder: (BuildContext context) {
                      return Center(
                        child: Text(
                          '没有数据',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                    itemBuilder:
                        (BuildContext context, int index, String item) {
                      return ListTile(
                        title: Text(item),
                        subtitle: Text('index $index'),
                      );
                    },
                  )
                : CustomPaging(
                    key: ValueKey<bool>(_useDefaultPhysics),
                    controller: _controller,
                    scrollController: _scrollController,
                    useDefaultPhysics: _useDefaultPhysics,
                    forceEmpty: _forceEmpty,
                    refreshOnStart: true,
                    itemBuilder:
                        (BuildContext context, int index, String item) {
                      return ListTile(
                        title: Text(item),
                        subtitle: Text('index $index'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

const int _demoPageSize = 10;
const int _demoTotalCount = 45;

Future<FastPagingPage<String>> _demoFetchPage({
  required int page,
  required bool forceEmpty,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 800));
  if (forceEmpty) {
    return const FastPagingPage<String>(
      page: 1,
      total: 0,
      items: <String>[],
    );
  }
  final int start = (page - 1) * _demoPageSize;
  if (start >= _demoTotalCount) {
    return FastPagingPage<String>(
      page: page,
      total: _demoTotalCount,
      items: const <String>[],
    );
  }
  final int end = start + _demoPageSize > _demoTotalCount
      ? _demoTotalCount
      : start + _demoPageSize;
  return FastPagingPage<String>(
    page: page,
    total: _demoTotalCount,
    items: List<String>.generate(
      end - start,
      (int i) => 'Item ${start + i + 1}',
    ),
  );
}

/// 示例分页：总共 45 条，每页 10 条。
class CustomPaging extends FastPaging<List<String>, String> {
  const CustomPaging({
    super.key,
    super.controller,
    super.scrollController,
    super.useDefaultPhysics,
    super.refreshOnStart,
    super.itemBuilder,
    this.forceEmpty = false,
  });

  /// 为 `true` 时刷新返回空列表，用来看空态。
  final bool forceEmpty;

  @override
  FastPagingState<List<String>, String, CustomPaging> createState() =>
      CustomPagingState();
}

class CustomPagingState
    extends FastPagingState<List<String>, String, CustomPaging> {
  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) => data![index];

  @override
  int? page;

  @override
  int? total;

  @override
  int? totalPage;

  @override
  Widget buildItem(BuildContext context, int index, String item) {
    return buildItemByBuilder(context, index, item);
  }

  @override
  Widget? buildRefreshOnStartWidget() {
    return const ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载第一页…'),
          ],
        ),
      ),
    );
  }

  @override
  Widget? buildEmptyWidget() {
    return Center(
      child: Text(
        '没有数据',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  @override
  Future<FastRefreshResult?> onRefresh() async {
    final FastPagingPage<String> response = await _demoFetchPage(
      page: 1,
      forceEmpty: widget.forceEmpty,
    );
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    setState(() {
      data = response.items.toList();
      total = response.total;
      page = response.page;
      totalPage = response.total == 0
          ? 0
          : (response.total! + _demoPageSize - 1) ~/ _demoPageSize;
    });
    return null;
  }

  @override
  Future<FastRefreshResult?> onLoad() async {
    final FastPagingPage<String> response = await _demoFetchPage(
      page: (page ?? 0) + 1,
      forceEmpty: widget.forceEmpty,
    );
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    setState(() {
      data = <String>[...?data, ...response.items];
      total = response.total;
      page = response.page;
      totalPage = response.total == 0
          ? 0
          : (response.total! + _demoPageSize - 1) ~/ _demoPageSize;
    });
    return null;
  }
}
