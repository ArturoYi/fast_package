import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {List<ThemeExtension<dynamic>>? extensions}) {
    return MaterialApp(
      theme: ThemeData(
        extensions: extensions ?? const <ThemeExtension<dynamic>>[],
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 400, height: 80, child: child),
        ),
      ),
    );
  }

  testWidgets('drag left reveals end pane action', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            children: <Widget>[
              FastSlidableAction(
                onPressed: (_) => pressed = true,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      ),
    );

    await tester.drag(find.text('Item'), const Offset(-180, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('drag right reveals start pane action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          startPane: FastSlidablePane(
            motion: FastSlidableMotion.scroll,
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: 'Share',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      ),
    );

    await tester.drag(find.text('Item'), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('controller opens and closes programmatically', (
    WidgetTester tester,
  ) async {
    late FastSlidableController controller;
    await tester.pumpWidget(
      MaterialApp(
        home: _ControllerHost(
          builder: (FastSlidableController value) {
            controller = value;
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 80,
                  child: FastSlidable(
                    controller: controller,
                    endPane: FastSlidablePane(
                      motion: FastSlidableMotion.behind,
                      children: const <Widget>[
                        FastSlidableAction(
                          onPressed: _noop,
                          backgroundColor: Color(0xFF7BC043),
                          icon: Icons.archive,
                          label: 'Archive',
                        ),
                      ],
                    ),
                    child: const ListTile(title: Text('Item')),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    final Future<void> open = controller.openEnd();
    await tester.pumpAndSettle();
    await open;
    expect(find.text('Archive'), findsOneWidget);
    expect(controller.paneType.value, FastSlidablePaneType.end);

    final Future<void> close = controller.close();
    await tester.pumpAndSettle();
    await close;
    expect(find.text('Archive'), findsNothing);
    expect(controller.paneType.value, FastSlidablePaneType.none);
  });

  testWidgets('group closes the previously open row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastSlidableGroup(
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 80,
                  child: FastSlidable(
                    groupTag: 'inbox',
                    endPane: FastSlidablePane(
                      motion: FastSlidableMotion.behind,
                      children: const <Widget>[
                        FastSlidableAction(
                          onPressed: _noop,
                          backgroundColor: Color(0xFFFE4A49),
                          icon: Icons.delete,
                          label: 'Delete-A',
                        ),
                      ],
                    ),
                    child: const ListTile(title: Text('A')),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: FastSlidable(
                    groupTag: 'inbox',
                    endPane: FastSlidablePane(
                      motion: FastSlidableMotion.behind,
                      children: const <Widget>[
                        FastSlidableAction(
                          onPressed: _noop,
                          backgroundColor: Color(0xFFFE4A49),
                          icon: Icons.delete,
                          label: 'Delete-B',
                        ),
                      ],
                    ),
                    child: const ListTile(title: Text('B')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.text('A'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete-A'), findsOneWidget);

    await tester.drag(
      find.text('B'),
      const Offset(-200, 0),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Delete-B'), findsOneWidget);
    expect(find.text('Delete-A'), findsNothing);
  });

  testWidgets('closeOnScroll closes an open pane', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              SizedBox(
                height: 80,
                child: FastSlidable(
                  endPane: FastSlidablePane(
                    motion: FastSlidableMotion.behind,
                    children: const <Widget>[
                      FastSlidableAction(
                        onPressed: _noop,
                        backgroundColor: Color(0xFFFE4A49),
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: const ListTile(title: Text('Item')),
                ),
              ),
              const SizedBox(height: 800, child: Text('tail')),
            ],
          ),
        ),
      ),
    );

    await tester.drag(find.text('Item'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);

    await tester.drag(find.text('tail'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('dismiss without key throws in debug', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            dismiss: FastSlidableDismiss(onDismissed: () {}),
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFFFE4A49),
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      ),
    );

    final Object? error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect('$error', contains('Key'));
  });

  testWidgets('full swipe past threshold dismisses the row', (
    WidgetTester tester,
  ) async {
    bool dismissed = false;
    bool triggered = false;
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          key: const ValueKey<String>('row'),
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            extentRatio: 0.4,
            dismiss: FastSlidableDismiss(
              threshold: 0.9,
              onDismissed: () => dismissed = true,
            ),
            fullSwipe: FastSlidableFullSwipe(
              threshold: 0.5,
              onTriggered: () => triggered = true,
            ),
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFFFE4A49),
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      ),
    );

    await tester.drag(find.text('Item'), const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(triggered, isTrue);
    expect(dismissed, isTrue);
  });

  testWidgets('full swipe fires on release without a follow-up tap', (
    WidgetTester tester,
  ) async {
    bool triggered = false;
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          key: const ValueKey<String>('row'),
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.scroll,
            extentRatio: 0.4,
            dismiss: FastSlidableDismiss(
              onDismissed: () {},
            ),
            fullSwipe: FastSlidableFullSwipe(
              threshold: 0.5,
              onTriggered: () => triggered = true,
            ),
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFFFE4A49),
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      ),
    );

    final Offset center = tester.getCenter(find.text('Item'));
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(
      const Offset(-280, 0),
      timeStamp: const Duration(milliseconds: 120),
    );
    await tester.pump();
    await gesture.up(timeStamp: const Duration(milliseconds: 160));
    await tester.pump();

    expect(triggered, isTrue);
  });

  testWidgets('list swipe-dismiss removes a middle row without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _DismissListHarness()));
    await tester.pumpAndSettle();

    expect(find.text('Mail 1'), findsOneWidget);
    expect(find.text('Mail 2'), findsOneWidget);
    expect(find.text('Mail 3'), findsOneWidget);

    await tester.drag(find.text('Mail 2'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Mail 1'), findsOneWidget);
    expect(find.text('Mail 2'), findsNothing);
    expect(find.text('Mail 3'), findsOneWidget);
  });

  testWidgets('dismiss then ancestor rebuild does not crash', (
    WidgetTester tester,
  ) async {
    final GlobalKey<_DismissListHarnessState> key =
        GlobalKey<_DismissListHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _DismissListHarness(key: key)));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Mail 1'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Mail 1'), findsNothing);

    key.currentState!.rebuild();
    await tester.pump();
    expect(find.text('Mail 2'), findsOneWidget);
    expect(find.text('Mail 3'), findsOneWidget);
  });

  testWidgets('rebuild after dismiss without removal does not throw', (
    WidgetTester tester,
  ) async {
    bool dismissed = false;
    Widget buildRow() {
      return wrap(
        FastSlidable(
          key: const ValueKey<String>('row'),
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            extentRatio: 0.4,
            dismiss: FastSlidableDismiss(
              threshold: 0.9,
              onDismissed: () => dismissed = true,
            ),
            fullSwipe: const FastSlidableFullSwipe(threshold: 0.5),
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFFFE4A49),
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: const ListTile(title: Text('Item')),
        ),
      );
    }

    await tester.pumpWidget(buildRow());
    await tester.drag(find.text('Item'), const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);

    await tester.pumpWidget(buildRow());
    await tester.pump();
    expect(find.text('Item'), findsOneWidget);
  });

  testWidgets('vertical drag reveals the end pane',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        FastSlidable(
          direction: Axis.vertical,
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            children: const <Widget>[
              FastSlidableAction(
                onPressed: _noop,
                backgroundColor: Color(0xFF0392CF),
                icon: Icons.save,
                label: 'Save',
              ),
            ],
          ),
          child: const ColoredBox(
            color: Color(0xFFE0E0E0),
            child: Center(child: Text('Card')),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Card'), const Offset(0, -50));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('theme resolve prefers ThemeExtension then overrides', (
    WidgetTester tester,
  ) async {
    late FastSlidableTheme resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[
            FastSlidableTheme(
              movementDuration: Duration(milliseconds: 120),
              movementCurve: Curves.linear,
              dismissDuration: Duration(milliseconds: 100),
              resizeDuration: Duration(milliseconds: 100),
              actionSpacing: 8,
              actionBorderRadius: 12,
              actionForegroundColor: Color(0xFF00FF00),
            ),
          ],
        ),
        home: Builder(
          builder: (BuildContext context) {
            resolved = FastSlidableTheme.resolve(
              context,
              actionSpacing: 10,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.actionSpacing, 10);
    expect(resolved.actionBorderRadius, 12);
    expect(resolved.movementDuration, const Duration(milliseconds: 120));
  });

  testWidgets('refresh processing locks horizontal drag', (
    WidgetTester tester,
  ) async {
    final FastRefreshController refresh = FastRefreshController(
      controlFinishRefresh: true,
    );
    addTearDown(refresh.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            controller: refresh,
            onRefresh: () async {},
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 80,
                  child: FastSlidable(
                    endPane: FastSlidablePane(
                      motion: FastSlidableMotion.behind,
                      children: const <Widget>[
                        FastSlidableAction(
                          onPressed: _noop,
                          backgroundColor: Color(0xFFFE4A49),
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: const ListTile(title: Text('Item')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final Future<dynamic> refreshing = refresh.callRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Keep the header in processing while we try to drag.
    // 保持 processing，再尝试横滑。

    await tester.drag(find.text('Item'), const Offset(-200, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Delete'), findsNothing);

    refresh.finishRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await refreshing;
  });

  testWidgets('vertical scroll under FastRefresh does not rebuild slidable', (
    WidgetTester tester,
  ) async {
    int builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            onRefresh: () async {},
            onLoad: () async => FastRefreshResult.noMore,
            child: ListView(
              children: <Widget>[
                for (int i = 0; i < 8; i++)
                  SizedBox(
                    height: 80,
                    child: FastSlidable(
                      endPane: FastSlidablePane(
                        motion: FastSlidableMotion.behind,
                        children: const <Widget>[
                          FastSlidableAction(
                            onPressed: _noop,
                            backgroundColor: Color(0xFFFE4A49),
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (BuildContext context) {
                          if (i == 0) {
                            builds += 1;
                          }
                          return ListTile(title: Text('Item $i'));
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final int afterSettle = builds;

    await tester.drag(find.byType(ListView), const Offset(0, 80));
    await tester.pump();
    expect(builds, afterSettle);
  });

  testWidgets('replacing an external controller does not dispose the old one', (
    WidgetTester tester,
  ) async {
    final GlobalKey<_ControllerSwapHarnessState> key =
        GlobalKey<_ControllerSwapHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 80,
              child: _ControllerSwapHarness(key: key, useFirst: true),
            ),
          ),
        ),
      ),
    );

    final _ControllerSwapHarnessState state = key.currentState!;
    final Future<void> openFirst = state.first.openEnd();
    await tester.pumpAndSettle();
    await openFirst;
    expect(find.text('Archive'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 80,
              child: _ControllerSwapHarness(key: key, useFirst: false),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Future<void> closeFirst = state.first.close();
    await tester.pumpAndSettle();
    await closeFirst;
    expect(state.first.paneType.value, FastSlidablePaneType.none);

    final Future<void> openSecond = state.second.openEnd();
    await tester.pumpAndSettle();
    await openSecond;
    expect(find.text('Archive'), findsOneWidget);
    expect(state.second.paneType.value, FastSlidablePaneType.end);
  });

  testWidgets('replacing an owned controller disposes it after the frame', (
    WidgetTester tester,
  ) async {
    final GlobalKey<_OptionalControllerHarnessState> key =
        GlobalKey<_OptionalControllerHarnessState>();
    FastSlidableController? seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 80,
              child: _OptionalControllerHarness(
                key: key,
                onSeen: (FastSlidableController controller) {
                  seen = controller;
                },
              ),
            ),
          ),
        ),
      ),
    );

    final FastSlidableController owned = seen!;
    expect(identical(owned, key.currentState!.external), isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 80,
              child: _OptionalControllerHarness(
                key: key,
                useExternal: true,
                onSeen: (FastSlidableController controller) {
                  seen = controller;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(identical(seen, key.currentState!.external), isTrue);
    expect(owned.close, throwsA(isA<AssertionError>()));
  });

  testWidgets('disposing the widget does not dispose an external controller', (
    WidgetTester tester,
  ) async {
    final GlobalKey<_PersistentControllerHarnessState> key =
        GlobalKey<_PersistentControllerHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: _PersistentControllerHarness(key: key, showSlidable: true),
      ),
    );

    final FastSlidableController controller = key.currentState!.controller;

    await tester.pumpWidget(
      MaterialApp(
        home: _PersistentControllerHarness(key: key, showSlidable: false),
      ),
    );

    final Future<void> close = controller.close();
    await tester.pumpAndSettle();
    await close;
    expect(controller.paneType.value, FastSlidablePaneType.none);
  });
}

void _noop(BuildContext context) {}

class _ControllerHost extends StatefulWidget {
  const _ControllerHost({required this.builder});

  final Widget Function(FastSlidableController controller) builder;

  @override
  State<_ControllerHost> createState() => _ControllerHostState();
}

class _ControllerHostState extends State<_ControllerHost>
    with SingleTickerProviderStateMixin {
  late final FastSlidableController controller = FastSlidableController(this);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(controller);
}

FastSlidablePane _archivePane() {
  return FastSlidablePane(
    motion: FastSlidableMotion.behind,
    children: const <Widget>[
      FastSlidableAction(
        onPressed: _noop,
        backgroundColor: Color(0xFF7BC043),
        icon: Icons.archive,
        label: 'Archive',
      ),
    ],
  );
}

class _ControllerSwapHarness extends StatefulWidget {
  const _ControllerSwapHarness({
    super.key,
    required this.useFirst,
  });

  final bool useFirst;

  @override
  State<_ControllerSwapHarness> createState() => _ControllerSwapHarnessState();
}

class _ControllerSwapHarnessState extends State<_ControllerSwapHarness>
    with TickerProviderStateMixin {
  late final FastSlidableController first = FastSlidableController(this);
  late final FastSlidableController second = FastSlidableController(this);

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FastSlidable(
      controller: widget.useFirst ? first : second,
      endPane: _archivePane(),
      child: const ListTile(title: Text('Item')),
    );
  }
}

class _OptionalControllerHarness extends StatefulWidget {
  const _OptionalControllerHarness({
    super.key,
    this.useExternal = false,
    required this.onSeen,
  });

  final bool useExternal;
  final ValueChanged<FastSlidableController> onSeen;

  @override
  State<_OptionalControllerHarness> createState() =>
      _OptionalControllerHarnessState();
}

class _OptionalControllerHarnessState extends State<_OptionalControllerHarness>
    with SingleTickerProviderStateMixin {
  late final FastSlidableController external = FastSlidableController(this);

  @override
  void dispose() {
    external.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FastSlidable(
      controller: widget.useExternal ? external : null,
      endPane: _archivePane(),
      child: Builder(
        builder: (BuildContext context) {
          widget.onSeen(FastSlidable.of(context)!);
          return const ListTile(title: Text('Item'));
        },
      ),
    );
  }
}

class _PersistentControllerHarness extends StatefulWidget {
  const _PersistentControllerHarness({
    super.key,
    required this.showSlidable,
  });

  final bool showSlidable;

  @override
  State<_PersistentControllerHarness> createState() =>
      _PersistentControllerHarnessState();
}

class _PersistentControllerHarnessState
    extends State<_PersistentControllerHarness>
    with SingleTickerProviderStateMixin {
  late final FastSlidableController controller = FastSlidableController(this);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 80,
          child: widget.showSlidable
              ? FastSlidable(
                  controller: controller,
                  endPane: _archivePane(),
                  child: const ListTile(title: Text('Item')),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DismissListHarness extends StatefulWidget {
  const _DismissListHarness({super.key});

  @override
  State<_DismissListHarness> createState() => _DismissListHarnessState();
}

class _DismissListHarnessState extends State<_DismissListHarness> {
  final List<String> items = <String>['Mail 1', 'Mail 2', 'Mail 3'];

  void rebuild() => setState(() {});

  void _remove(String item) {
    setState(() {
      items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FastSlidableGroup(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final String item = items[index];
            return FastSlidable(
              key: ValueKey<String>(item),
              groupTag: 'mail',
              endPane: FastSlidablePane(
                motion: FastSlidableMotion.drawer,
                dismiss: FastSlidableDismiss(
                  onDismissed: () => _remove(item),
                ),
                fullSwipe: const FastSlidableFullSwipe(threshold: 0.55),
                children: <Widget>[
                  FastSlidableAction(
                    onPressed: (_) {},
                    backgroundColor: const Color(0xFF7BC043),
                    icon: Icons.archive,
                    label: 'Archive',
                  ),
                  FastSlidableAction(
                    onPressed: (_) => _remove(item),
                    backgroundColor: const Color(0xFFFE4A49),
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(title: Text(item)),
            );
          },
        ),
      ),
    );
  }
}
