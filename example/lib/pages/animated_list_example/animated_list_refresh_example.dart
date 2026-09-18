import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class AnimatedListRefreshExample extends StatefulWidget {
  const AnimatedListRefreshExample({super.key});

  @override
  State<AnimatedListRefreshExample> createState() =>
      _AnimatedListRefreshExampleState();
}

class _AnimatedListRefreshExampleState
    extends State<AnimatedListRefreshExample> {
  final FastRefreshController _refresh = FastRefreshController();
  List<String> _items = List<String>.generate(8, (int i) => 'Row ${i + 1}');
  int _page = 1;

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    setState(() {
      _page = 1;
      _items = List<String>.generate(8, (int i) => 'Row ${i + 1}');
    });
  }

  Future<void> _onLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    setState(() {
      _page++;
      _items = <String>[
        ..._items,
        ...List<String>.generate(
          6,
          (int i) => 'Row ${(_page - 1) * 6 + i + 9}',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated List · Refresh')),
      body: FastRefresh.builder(
        controller: _refresh,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        childBuilder: (BuildContext context, ScrollPhysics physics) {
          return CustomScrollView(
            physics: physics,
            slivers: <Widget>[
              FastSliverAnimatedCompositeList<String>(
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
                  return ListTile(
                    title: Text(item),
                    subtitle: const Text(
                      'Long-press to drag · pull to refresh',
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
