import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListGridExample extends StatefulWidget {
  const AnimatedListGridExample({super.key});

  @override
  State<AnimatedListGridExample> createState() =>
      _AnimatedListGridExampleState();
}

class _AnimatedListGridExampleState extends State<AnimatedListGridExample> {
  final List<int> _items = List<int>.generate(12, (int i) => i);
  int _next = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated List · Grid'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _items.add(_next++);
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FastAnimatedList<int>.grid(
        padding: const EdgeInsets.all(12),
        items: _items,
        itemId: (int e) => e,
        entrance: FastListEntrance.scale,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (BuildContext context, int item, int index) {
          return Material(
            color: Colors.deepPurple.shade200,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _items.remove(item);
                });
              },
              child: Center(
                child: Text(
                  '#$item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
