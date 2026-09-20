import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Horizontal FastSlidable + handle reorder.
class AnimatedListSlidableExample extends StatefulWidget {
  const AnimatedListSlidableExample({super.key});

  @override
  State<AnimatedListSlidableExample> createState() =>
      _AnimatedListSlidableExampleState();
}

class _AnimatedListSlidableExampleState
    extends State<AnimatedListSlidableExample> {
  final DemoCatalog _catalog = DemoCatalog();
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  FastListDragTrigger _trigger = FastListDragTrigger.handle;

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
    final bool handle = _trigger == FastListDragTrigger.handle;
    return Scaffold(
      appBar: AppBar(title: const Text('配合 Slidable')),
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
                  '${demoLayoutCaption(_scroll, _cells)} 右滑归档，左滑删除（可满滑）。拖拽请用手柄，避免和水平滑动抢手势。',
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
                        title: 'Slidable',
                        subtitle: '水平滑操作 · 手柄排序',
                        count: _catalog.items.length,
                      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
