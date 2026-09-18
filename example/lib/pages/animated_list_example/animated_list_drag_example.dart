import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListDragExample extends StatefulWidget {
  const AnimatedListDragExample({super.key});

  @override
  State<AnimatedListDragExample> createState() =>
      _AnimatedListDragExampleState();
}

class _AnimatedListDragExampleState extends State<AnimatedListDragExample> {
  final List<String> _items = <String>[
    'Inbox',
    'Starred',
    'Snoozed',
    'Important',
    'Sent',
    'Drafts',
    'Archive',
    'Trash',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reorderable List · Drag')),
      body: FastReorderableList<String>(
        items: _items,
        itemId: (String e) => e,
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
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item),
              subtitle: const Text('Long-press to drag'),
            ),
          );
        },
      ),
    );
  }
}
