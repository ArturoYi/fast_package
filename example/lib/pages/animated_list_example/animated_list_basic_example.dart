import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListBasicExample extends StatefulWidget {
  const AnimatedListBasicExample({super.key});

  @override
  State<AnimatedListBasicExample> createState() =>
      _AnimatedListBasicExampleState();
}

class _AnimatedListBasicExampleState extends State<AnimatedListBasicExample> {
  final List<_Note> _items = List<_Note>.generate(
    8,
    (int i) => _Note(id: i, title: 'Note ${i + 1}'),
  );
  int _nextId = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List · Basic')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _items.insert(0, _Note(id: _nextId, title: 'Note ${_nextId + 1}'));
            _nextId++;
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FastAnimatedList<_Note>(
        items: _items,
        itemId: (_Note e) => e.id,
        itemBuilder: (BuildContext context, _Note item, int index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(item.title),
              subtitle: Text('id ${item.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _items.removeWhere((_Note e) => e.id == item.id);
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

class _Note {
  const _Note({required this.id, required this.title});

  final int id;
  final String title;
}
