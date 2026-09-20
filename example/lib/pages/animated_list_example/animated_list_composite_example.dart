import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Insert / remove plus drag, across List · Grid · Sliver · Column.
class AnimatedListCompositeExample extends StatefulWidget {
  const AnimatedListCompositeExample({super.key});

  @override
  State<AnimatedListCompositeExample> createState() =>
      _AnimatedListCompositeExampleState();
}

class _AnimatedListCompositeExampleState
    extends State<AnimatedListCompositeExample> {
  final DemoCatalog _catalog = DemoCatalog();
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  FastListDragTrigger _trigger = FastListDragTrigger.handle;

  @override
  Widget build(BuildContext context) {
    final bool handle = _trigger == FastListDragTrigger.handle;
    return Scaffold(
      appBar: AppBar(title: const Text('增删 + 拖拽')),
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
                '${demoLayoutCaption(_scroll, _cells)} 增删走 AnimatedList，拖完用零时长 move 对齐。',
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
          Expanded(
            child: buildDemoList(
              scroll: _scroll,
              cells: _cells,
              mode: DemoListMode.both,
              items: _catalog.items,
              dragTrigger: _trigger,
              onReorder: (int from, int to) {
                setState(() => _catalog.reorder(from, to));
              },
              header: _scroll == DemoScroll.box
                  ? null
                  : DemoHeroBanner(
                      title: '增删 + 排序',
                      subtitle: handle ? '手柄拖 · 按钮增删' : '长按拖 · 按钮增删',
                      count: _catalog.items.length,
                    ),
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
            ),
          ),
        ],
      ),
    );
  }
}
