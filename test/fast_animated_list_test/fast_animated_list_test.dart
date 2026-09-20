import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {List<ThemeExtension<dynamic>>? extensions}) {
    return MaterialApp(
      theme: ThemeData(
        extensions: extensions ?? const <ThemeExtension<dynamic>>[],
      ),
      home: Scaffold(body: child),
    );
  }

  testWidgets('insert and remove animate the tile in and out', (
    WidgetTester tester,
  ) async {
    final List<String> items = <String>['A', 'B'];

    await tester.pumpWidget(
      wrap(
        _Host(
          items: items,
          builder: (List<String> current, ValueChanged<List<String>> update) {
            return FastAnimatedList<String>(
              items: current,
              itemId: (String e) => e,
              itemBuilder: (BuildContext context, String item, int index) {
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      update(List<String>.of(current)..remove(item));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    final _HostState state = tester.state<_HostState>(find.byType(_Host));
    state.update(<String>['A', 'B', 'C']);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('C'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('batch append staggers later tiles behind earlier ones', (
    WidgetTester tester,
  ) async {
    final List<String> items = <String>['A', 'B'];

    await tester.pumpWidget(
      wrap(
        _Host(
          items: items,
          builder: (List<String> current, ValueChanged<List<String>> update) {
            return FastAnimatedList<String>(
              items: current,
              itemId: (String e) => e,
              stagger: const FastListStagger.list(
                duration: Duration(milliseconds: 225),
                delay: Duration(milliseconds: 40),
              ),
              itemBuilder: (BuildContext context, String item, int index) {
                return SizedBox(height: 48, child: Text(item));
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.state<_HostState>(find.byType(_Host)).update(
      <String>['A', 'B', 'C', 'D', 'E'],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    double factorOf(String label) {
      return tester
          .widget<SizeTransition>(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(SizeTransition),
                )
                .first,
          )
          .sizeFactor
          .value;
    }

    expect(factorOf('C'), greaterThan(0));
    expect(factorOf('E'), 0);

    await tester.pumpAndSettle();
    expect(find.text('E'), findsOneWidget);
  });

  testWidgets('long-press drag reports Flutter-style onReorder', (
    WidgetTester tester,
  ) async {
    int? from;
    int? to;
    final List<String> items = <String>['A', 'B', 'C'];

    await tester.pumpWidget(
      wrap(
        _Host(
          items: items,
          builder: (List<String> current, ValueChanged<List<String>> update) {
            return FastReorderableList<String>(
              items: current,
              itemId: (String e) => e,
              itemExtent: 72,
              onReorder: (int oldIndex, int newIndex) {
                from = oldIndex;
                to = newIndex;
                final List<String> next = List<String>.of(current);
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                next.insert(newIndex, next.removeAt(oldIndex));
                update(next);
              },
              itemBuilder: (BuildContext context, String item, int index) {
                return ListTile(title: Text(item));
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.text('A'));
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 450));
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(from, 0);
    expect(to, isNotNull);
    expect(to! > from!, isTrue);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('handle drag on FastAnimatedReorderableList reports onReorder', (
    WidgetTester tester,
  ) async {
    int? from;
    int? to;
    final List<String> items = <String>['A', 'B', 'C'];

    await tester.pumpWidget(
      wrap(
        _Host(
          items: items,
          builder: (List<String> current, ValueChanged<List<String>> update) {
            return FastAnimatedReorderableList<String>(
              items: current,
              itemId: (String e) => e,
              itemExtent: 72,
              dragTrigger: FastListDragTrigger.handle,
              onReorder: (int oldIndex, int newIndex) {
                from = oldIndex;
                to = newIndex;
                final List<String> next = List<String>.of(current);
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                next.insert(newIndex, next.removeAt(oldIndex));
                update(next);
              },
              itemBuilder: (BuildContext context, String item, int index) {
                return ListTile(
                  leading: const FastListDragHandle(
                    child: Icon(Icons.drag_handle),
                  ),
                  title: Text(item),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.byIcon(Icons.drag_handle).first);
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(from, 0);
    expect(to, isNotNull);
    expect(to! > from!, isTrue);
    expect(
      tester.state<_HostState>(find.byType(_Host)).items,
      <String>['B', 'C', 'A'],
    );
  });

  testWidgets('tapping a drag handle does not reorder', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    final List<String> items = <String>['A', 'B'];

    await tester.pumpWidget(
      wrap(
        _Host(
          items: items,
          builder: (List<String> current, ValueChanged<List<String>> update) {
            return FastAnimatedReorderableList<String>(
              items: current,
              itemId: (String e) => e,
              itemExtent: 72,
              dragTrigger: FastListDragTrigger.handle,
              onReorder: (int oldIndex, int newIndex) {
                calls += 1;
              },
              itemBuilder: (BuildContext context, String item, int index) {
                return ListTile(
                  leading: const FastListDragHandle(
                    child: Icon(Icons.drag_handle),
                  ),
                  title: Text(item),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.drag_handle).first);
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(
      tester.state<_HostState>(find.byType(_Host)).items,
      <String>['A', 'B'],
    );
  });

  testWidgets('theme resolve prefers widget overrides', (
    WidgetTester tester,
  ) async {
    late FastAnimatedListTheme resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[
            FastAnimatedListTheme.light,
          ],
        ),
        home: Builder(
          builder: (BuildContext context) {
            resolved = FastAnimatedListTheme.resolve(
              context,
              insertDuration: const Duration(milliseconds: 90),
              slideOffset: 12,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.insertDuration, const Duration(milliseconds: 90));
    expect(resolved.slideOffset, 12);
    expect(
      resolved.removeDuration,
      FastAnimatedListTheme.light.removeDuration,
    );
  });

  testWidgets('scrolling under FastRefresh does not rebuild settled tiles', (
    WidgetTester tester,
  ) async {
    final Map<String, int> builds = <String, int>{};

    await tester.pumpWidget(
      wrap(
        FastRefresh(
          onRefresh: () async {},
          onLoad: () async => FastRefreshResult.noMore,
          child: FastAnimatedReorderableList<String>(
            items: const <String>['A', 'B', 'C', 'D'],
            itemId: (String e) => e,
            itemExtent: 72,
            onReorder: (int from, int to) {},
            itemBuilder: (BuildContext context, String item, int index) {
              return _BuildProbe(
                onBuild: () {
                  builds[item] = (builds[item] ?? 0) + 1;
                },
                child: ListTile(title: Text(item)),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final int afterSettle = builds['A']!;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 64));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(builds['A'], afterSettle);
  });

  testWidgets('FastStagger children appear after the first frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        FastStagger(
          child: Column(
            children: FastStagger.children(
              children: const <Widget>[
                Text('One'),
                Text('Two'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
  });
}

class _BuildProbe extends StatelessWidget {
  const _BuildProbe({
    required this.onBuild,
    required this.child,
  });

  final VoidCallback onBuild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return child;
  }
}

class _Host extends StatefulWidget {
  const _Host({
    required this.items,
    required this.builder,
  });

  final List<String> items;
  final Widget Function(
    List<String> items,
    ValueChanged<List<String>> update,
  ) builder;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> items = List<String>.of(widget.items);

  void update(List<String> next) {
    setState(() {
      items = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(items, update);
  }
}
