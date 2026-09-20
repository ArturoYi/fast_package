import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// FastRefresh + animated / reorderable list.
class AnimatedListRefreshExample extends StatefulWidget {
  const AnimatedListRefreshExample({super.key});

  @override
  State<AnimatedListRefreshExample> createState() =>
      _AnimatedListRefreshExampleState();
}

class _AnimatedListRefreshExampleState
    extends State<AnimatedListRefreshExample> {
  final DemoCatalog _catalog = DemoCatalog();
  final FastRefreshController _refresh = FastRefreshController();
  final ScrollController _scrollController = ScrollController();
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  FastListDragTrigger _trigger = FastListDragTrigger.longPress;
  int _page = 1;

  @override
  void dispose() {
    _refresh.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<FastRefreshResult> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    setState(() {
      _page = 1;
      _catalog.reset(count: 8);
    });
    return FastRefreshResult.success;
  }

  Future<FastRefreshResult> _onLoad() async {
    if (_page >= 3) {
      return FastRefreshResult.noMore;
    }
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    setState(() {
      _page += 1;
      _catalog.insertBatch(6);
    });
    return _page >= 3 ? FastRefreshResult.noMore : FastRefreshResult.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配合 Refresh')),
      body: Column(
        children: <Widget>[
          DemoLayoutBar(
            scroll: _scroll,
            cells: _cells,
            onScroll: (DemoScroll value) => setState(() => _scroll = value),
            onCells: (DemoCells value) => setState(() => _cells = value),
          ),
          DemoDragTriggerBar(
            trigger: _trigger,
            onChanged: (FastListDragTrigger value) {
              setState(() => _trigger = value);
            },
          ),
          DemoCaption(
            text:
                '${demoLayoutCaption(_scroll, _cells)} 下拉会换一批 identity（大 diff 整表对齐）；上拉 +6 条在加载 / 滑动中零时长对齐，避免打断惯性。刷新中会锁拖拽。',
          ),
          DemoToolbar(
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _catalog.insertOne()),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('顶部 +1'),
              ),
              FilledButton.tonalIcon(
                onPressed: _catalog.items.isEmpty
                    ? null
                    : () => setState(() => _catalog.removeBatch(1)),
                icon: const Icon(Icons.remove, size: 18),
                label: const Text('删末尾'),
              ),
              TextButton(
                onPressed: () => _refresh.callRefresh(
                  scrollController: _scrollController,
                ),
                child: const Text('callRefresh'),
              ),
            ],
          ),
          Expanded(child: _buildRefresh()),
        ],
      ),
    );
  }

  Widget _buildRefresh() {
    final bool handle = _trigger == FastListDragTrigger.handle;
    final Widget header = DemoHeroBanner(
      title: 'Refresh + 列表',
      subtitle: '第 $_page 页 · 还可加载 ${3 - _page} 次',
      count: _catalog.items.length,
    );

    Widget list({ScrollPhysics? physics}) {
      return buildDemoList(
        scroll: _scroll,
        cells: _cells,
        mode: DemoListMode.both,
        items: _catalog.items,
        dragTrigger: _trigger,
        physics: physics,
        scrollController: _scrollController,
        onReorder: (int from, int to) {
          setState(() => _catalog.reorder(from, to));
        },
        header: _scroll == DemoScroll.box ? null : header,
        itemBuilder: (BuildContext context, DemoItem item, int index) {
          return _cells == DemoCells.grid
              ? DemoItemCard(
                  item: item,
                  index: index,
                  showHandle: handle,
                  onDelete: () => setState(() => _catalog.remove(item)),
                )
              : DemoItemTile(
                  item: item,
                  index: index,
                  showHandle: handle,
                  onDelete: () => setState(() => _catalog.remove(item)),
                );
        },
      );
    }

    if (_scroll == DemoScroll.sliver) {
      return FastRefresh.builder(
        controller: _refresh,
        scrollController: _scrollController,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        childBuilder: (BuildContext context, ScrollPhysics physics) {
          return list(physics: physics);
        },
      );
    }

    return FastRefresh(
      controller: _refresh,
      scrollController: _scrollController,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      child: list(),
    );
  }
}
