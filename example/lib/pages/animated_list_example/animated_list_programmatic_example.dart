import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListProgrammaticExample extends StatefulWidget {
  const AnimatedListProgrammaticExample({super.key});

  @override
  State<AnimatedListProgrammaticExample> createState() =>
      _AnimatedListProgrammaticExampleState();
}

class _AnimatedListProgrammaticExampleState
    extends State<AnimatedListProgrammaticExample> {
  final FastAnimatedCompositeListController _controller =
      FastAnimatedCompositeListController();
  final List<String> _items = <String>['Alpha', 'Bravo', 'Charlie', 'Delta'];
  int _seed = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Composite · Handle'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Insert',
            onPressed: () {
              setState(() {
                _items.insert(0, 'Item ${_seed++}');
              });
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Remove last',
            onPressed: _items.isEmpty
                ? null
                : () {
                    setState(() {
                      _items.removeLast();
                    });
                  },
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: FastAnimatedCompositeList<String>(
        controller: _controller,
        items: _items,
        itemId: (String e) => e,
        dragTrigger: FastListDragTrigger.handle,
        onReorder: (int from, int to) {
          setState(() {
            if (from < to) {
              to -= 1;
            }
            _items.insert(to, _items.removeAt(from));
          });
        },
        itemBuilder: (BuildContext context, String item, int index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const FastListDragHandle(child: Icon(Icons.drag_handle)),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _items.remove(item);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
