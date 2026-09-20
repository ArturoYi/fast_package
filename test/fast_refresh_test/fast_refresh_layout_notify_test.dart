import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('notifying footer during layout does not throw', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FastRefresh.builder(
          onLoad: () async {},
          childBuilder: (BuildContext context, ScrollPhysics physics) {
            return CustomScrollView(
              physics: physics,
              slivers: <Widget>[
                SliverLayoutBuilder(
                  builder:
                      (BuildContext context, SliverConstraints constraints) {
                    FastRefresh.maybeOf(context)
                        ?.footerNotifier
                        .notifyListeners();
                    return const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 800,
                        child: Text('body'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('batch append after load does not schedule a mid-frame build', (
    WidgetTester tester,
  ) async {
    final List<String> items = List<String>.generate(
      8,
      (int i) => 'Row ${i + 1}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _AnimatedLoadHost(items: items),
      ),
    );
    await tester.pumpAndSettle();

    final _AnimatedLoadHostState state = tester.state<_AnimatedLoadHostState>(
      find.byType(_AnimatedLoadHost),
    );
    state.appendBatch();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Row 1'), findsOneWidget);
    expect(state.items, hasLength(14));
  });

  testWidgets('tail append during load-more is layout-stable', (
    WidgetTester tester,
  ) async {
    final Completer<void> holdLoad = Completer<void>();
    final List<String> items = List<String>.generate(
      12,
      (int i) => 'Row ${i + 1}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _AnimatedLoadHost(
          items: items,
          onLoad: () => holdLoad.future,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final _AnimatedLoadHostState state = tester.state<_AnimatedLoadHostState>(
      find.byType(_AnimatedLoadHost),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    state.appendBatch();
    await tester.pump();

    expect(state.items, hasLength(18));
    final Iterable<SizeTransition> growing =
        tester.widgetList<SizeTransition>(find.byType(SizeTransition)).where(
              (SizeTransition transition) => transition.sizeFactor.value < 0.999,
            );
    expect(growing, isEmpty);

    holdLoad.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.takeException(), isNull);
  });
}

class _AnimatedLoadHost extends StatefulWidget {
  const _AnimatedLoadHost({
    required this.items,
    this.onLoad,
  });

  final List<String> items;
  final Future<void> Function()? onLoad;

  @override
  State<_AnimatedLoadHost> createState() => _AnimatedLoadHostState();
}

class _AnimatedLoadHostState extends State<_AnimatedLoadHost> {
  late List<String> items = List<String>.of(widget.items);

  void appendBatch() {
    setState(() {
      items = <String>[
        ...items,
        ...List<String>.generate(6, (int i) => 'Row ${items.length + i + 1}'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FastRefresh.builder(
        onLoad: widget.onLoad ?? () async {},
        childBuilder: (BuildContext context, ScrollPhysics physics) {
          return CustomScrollView(
            physics: physics,
            slivers: <Widget>[
              FastSliverAnimatedList<String>(
                items: items,
                itemId: (String e) => e,
                stagger: const FastListStagger.list(
                  duration: Duration(milliseconds: 225),
                  delay: Duration(milliseconds: 40),
                ),
                itemBuilder: (BuildContext context, String item, int index) {
                  return SizedBox(height: 48, child: Text(item));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
