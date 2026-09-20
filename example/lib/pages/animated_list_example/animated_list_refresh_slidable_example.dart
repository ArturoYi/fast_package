import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// FastRefresh + FastSlidable + insert/remove + drag.
class AnimatedListRefreshSlidableExample extends StatefulWidget {
  const AnimatedListRefreshSlidableExample({super.key});

  @override
  State<AnimatedListRefreshSlidableExample> createState() =>
      _AnimatedListRefreshSlidableExampleState();
}

class _AnimatedListRefreshSlidableExampleState
    extends State<AnimatedListRefreshSlidableExample> {
  final DemoCatalog _catalog = DemoCatalog();
  final FastRefreshController _refresh = FastRefreshController();
  final ScrollController _scrollController = ScrollController();
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  FastListDragTrigger _trigger = FastListDragTrigger.handle;
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

  void _archive(DemoItem item) {
    setState(() => _catalog.remove(item));
    showToast('已归档 ${item.title}');
  }

  void _delete(DemoItem item) {
    setState(() => _catalog.remove(item));
    showToast('已删除 ${item.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh + Slidable')),
      body: FastSlidableGroup(
        child: Column(
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
                  '${demoLayoutCaption(_scroll, _cells)} 下拉刷新、上拉加载、左滑删除、手柄排序叠在一起。上拉追加在加载 / 滑动中零时长对齐。刷新进行中会锁拖拽和滑动。',
            ),
            DemoToolbar(
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _catalog.insertOne()),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('顶部 +1'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _catalog.insertBatch(4)),
                  icon: const Icon(Icons.library_add_outlined, size: 18),
                  label: const Text('批量 +4'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _catalog.items.isEmpty
                      ? null
                      : () => setState(() => _catalog.removeBatch(1)),
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('删末尾'),
                ),
                TextButton(
                  onPressed: () => setState(() => _catalog.reset()),
                  child: const Text('重置'),
                ),
              ],
            ),
            Expanded(child: _buildRefresh()),
          ],
        ),
      ),
    );
  }

  Widget _buildRefresh() {
    final bool handle = _trigger == FastListDragTrigger.handle;
    final Widget header = DemoHeroBanner(
      title: '全组合',
      subtitle: 'Refresh · Slidable · 增删 · 拖拽',
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
          final Widget tile = _cells == DemoCells.grid
              ? DemoItemCard(
                  item: item,
                  index: index,
                  showHandle: handle,
                )
              : DemoItemTile(
                  item: item,
                  index: index,
                  showHandle: handle,
                );
          return demoSlidable(
            item: item,
            onDelete: () => _delete(item),
            onArchive: () => _archive(item),
            child: tile,
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
