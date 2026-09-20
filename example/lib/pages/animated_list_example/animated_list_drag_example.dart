import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Drag-only reorder across List · Grid · Sliver · Column.
class AnimatedListDragExample extends StatefulWidget {
  const AnimatedListDragExample({super.key});

  @override
  State<AnimatedListDragExample> createState() => _AnimatedListDragExampleState();
}

class _AnimatedListDragExampleState extends State<AnimatedListDragExample> {
  final DemoCatalog _catalog = DemoCatalog(count: 10);
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  FastListDragTrigger _trigger = FastListDragTrigger.longPress;

  @override
  Widget build(BuildContext context) {
    final bool handle = _trigger == FastListDragTrigger.handle;
    return Scaffold(
      appBar: AppBar(title: const Text('拖拽排序')),
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
            text: handle
                ? '${demoLayoutCaption(_scroll, _cells)} 按住手柄上下拖。'
                : '${demoLayoutCaption(_scroll, _cells)} 长按一行再拖。',
          ),
          Expanded(
            child: buildDemoList(
              scroll: _scroll,
              cells: _cells,
              mode: DemoListMode.reorder,
              items: _catalog.items,
              dragTrigger: _trigger,
              onReorder: (int from, int to) {
                setState(() => _catalog.reorder(from, to));
              },
              header: _scroll == DemoScroll.box
                  ? null
                  : DemoHeroBanner(
                      title: '只排序',
                      subtitle: handle ? '从手柄提起' : '长按提起',
                      count: _catalog.items.length,
                    ),
              itemBuilder: (BuildContext context, DemoItem item, int index) {
                return _cells == DemoCells.grid
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
