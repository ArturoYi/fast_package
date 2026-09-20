import 'package:example/pages/animated_list_example/animated_list_demo.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Insert / remove / batch insert, across List · Grid · Sliver · Column.
class AnimatedListMutationsExample extends StatefulWidget {
  const AnimatedListMutationsExample({super.key});

  @override
  State<AnimatedListMutationsExample> createState() =>
      _AnimatedListMutationsExampleState();
}

class _AnimatedListMutationsExampleState
    extends State<AnimatedListMutationsExample> {
  final DemoCatalog _catalog = DemoCatalog();
  DemoScroll _scroll = DemoScroll.box;
  DemoCells _cells = DemoCells.list;
  bool _staggerColumn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('增删 / 批量增删')),
      body: Column(
        children: <Widget>[
          DemoLayoutBar(
            scroll: _scroll,
            cells: _cells,
            onScroll: (DemoScroll value) => setState(() => _scroll = value),
            onCells: (DemoCells value) => setState(() => _cells = value),
          ),
          DemoCaption(text: demoLayoutCaption(_scroll, _cells)),
          DemoToolbar(
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _catalog.insertOne()),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('顶部 +1'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _catalog.insertBatch(5)),
                icon: const Icon(Icons.library_add_outlined, size: 18),
                label: const Text('批量 +5'),
              ),
              FilledButton.tonalIcon(
                onPressed: _catalog.items.isEmpty
                    ? null
                    : () => setState(() => _catalog.removeBatch(1)),
                icon: const Icon(Icons.remove, size: 18),
                label: const Text('删末尾'),
              ),
              FilledButton.tonalIcon(
                onPressed: _catalog.items.length < 3
                    ? null
                    : () => setState(() => _catalog.removeBatch(3)),
                icon: const Icon(Icons.remove_done, size: 18),
                label: const Text('批量 -3'),
              ),
              TextButton(
                onPressed: () => setState(() => _catalog.reset()),
                child: const Text('重置'),
              ),
            ],
          ),
          if (_scroll == DemoScroll.column) ...<Widget>[
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('改用 FastStagger（只要入场）'),
              subtitle: const Text('关掉则仍是 shrinkWrap FastAnimatedList，增删有动画'),
              value: _staggerColumn,
              onChanged: (bool value) {
                setState(() => _staggerColumn = value);
              },
            ),
            const DemoCaption(
              text:
                  'Column 默认 shrinkWrap 嵌进 SingleChildScrollView。FastStagger 给静态 Column / 自定义列表用，不做 identity diff。',
            ),
          ],
          Expanded(
            child: _scroll == DemoScroll.column && _staggerColumn
                ? _buildStaggerColumn()
                : buildDemoList(
                    scroll: _scroll,
                    cells: _cells,
                    mode: DemoListMode.mutations,
                    items: _catalog.items,
                    header: _scroll == DemoScroll.box
                        ? null
                        : DemoHeroBanner(
                            title: '增删动画',
                            subtitle: '插入走 Size + Fade，网格用 Scale',
                            count: _catalog.items.length,
                          ),
                    itemBuilder:
                        (BuildContext context, DemoItem item, int index) {
                      return _cells == DemoCells.grid
                          ? DemoItemCard(
                              item: item,
                              index: index,
                              onDelete: () =>
                                  setState(() => _catalog.remove(item)),
                            )
                          : DemoItemTile(
                              item: item,
                              index: index,
                              onDelete: () =>
                                  setState(() => _catalog.remove(item)),
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggerColumn() {
    final List<DemoItem> items = _catalog.items;
    return SingleChildScrollView(
      child: FastStagger(
        key: ValueKey<int>(items.length),
        stagger: _cells == DemoCells.grid
            ? const FastListStagger.grid(columnCount: 2)
            : const FastListStagger.list(),
        entrance: _cells == DemoCells.grid
            ? FastListEntrance.scale
            : FastListEntrance.fadeSlide,
        child: _cells == DemoCells.grid
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                gridDelegate: kDemoGridDelegate,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return FastStagger.item(
                    position: index,
                    entrance: FastListEntrance.scale,
                    child: DemoItemCard(
                      item: items[index],
                      index: index,
                      onDelete: () => setState(() => _catalog.remove(items[index])),
                    ),
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Column(
                  children: FastStagger.children(
                    children: <Widget>[
                      for (int i = 0; i < items.length; i++)
                        DemoItemTile(
                          item: items[i],
                          index: i,
                          onDelete: () =>
                              setState(() => _catalog.remove(items[i])),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
