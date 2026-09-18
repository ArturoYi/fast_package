import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListSlidableExample extends StatefulWidget {
  const AnimatedListSlidableExample({super.key});

  @override
  State<AnimatedListSlidableExample> createState() =>
      _AnimatedListSlidableExampleState();
}

class _AnimatedListSlidableExampleState
    extends State<AnimatedListSlidableExample> {
  final List<String> _items = List<String>.generate(
    8,
    (int i) => 'Message ${i + 1}',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List · Slidable')),
      body: FastSlidableGroup(
        child: FastAnimatedCompositeList<String>(
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
            return FastSlidable(
              key: ValueKey<String>(item),
              groupTag: 'inbox',
              endPane: FastSlidablePane(
                motion: FastSlidableMotion.scroll,
                dismiss: FastSlidableDismiss(
                  onDismissed: () {
                    setState(() {
                      _items.remove(item);
                    });
                    showToast('Removed $item');
                  },
                ),
                children: <Widget>[
                  FastSlidableAction(
                    onPressed: (_) {
                      setState(() {
                        _items.remove(item);
                      });
                    },
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                leading: const FastListDragHandle(
                  child: Icon(Icons.drag_handle),
                ),
                title: Text(item),
                subtitle: const Text('Swipe to delete · handle to reorder'),
              ),
            );
          },
        ),
      ),
    );
  }
}
