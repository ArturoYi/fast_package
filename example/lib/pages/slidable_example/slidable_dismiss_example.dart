import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Dismiss and iOS-style full swipe.
class SlidableDismissExample extends StatefulWidget {
  const SlidableDismissExample({super.key});

  @override
  State<SlidableDismissExample> createState() => _SlidableDismissExampleState();
}

class _SlidableDismissExampleState extends State<SlidableDismissExample> {
  final List<String> _items = List<String>.generate(
    8,
    (int i) => 'Mail ${i + 1}',
  );

  void _remove(String item) {
    setState(() {
      _items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slidable · Dismiss')),
      body: FastSlidableGroup(
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            final String item = _items[index];
            return FastSlidable(
              key: ValueKey<String>(item),
              groupTag: 'mail',
              startPane: FastSlidablePane(
                motion: FastSlidableMotion.drawer,
                children: <Widget>[
                  FastSlidableAction(
                    onPressed: (_) => showToast('Unread $item'),
                    backgroundColor: const Color(0xFF0392CF),
                    foregroundColor: Colors.white,
                    icon: Icons.mark_email_unread,
                    label: 'Unread',
                  ),
                ],
              ),
              endPane: FastSlidablePane(
                motion: FastSlidableMotion.drawer,
                dismiss: FastSlidableDismiss(
                  onDismissed: () {
                    _remove(item);
                    showToast('Removed $item');
                  },
                ),
                fullSwipe: const FastSlidableFullSwipe(threshold: 0.55),
                children: <Widget>[
                  FastSlidableAction(
                    onPressed: (_) => showToast('Archive $item'),
                    backgroundColor: const Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Archive',
                  ),
                  FastSlidableAction(
                    onPressed: (_) => _remove(item),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(item),
                subtitle: const Text('Swipe a little for buttons, farther to delete'),
              ),
            );
          },
        ),
      ),
    );
  }
}
