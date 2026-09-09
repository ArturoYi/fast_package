import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _HorizontalHarness extends StatefulWidget {
  const _HorizontalHarness();

  @override
  State<_HorizontalHarness> createState() => _HorizontalHarnessState();
}

class _HorizontalHarnessState extends State<_HorizontalHarness> {
  final FastRefreshController controller = FastRefreshController();
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable headerListenable =
      FastRefreshStateListenable();
  final FastRefreshStateListenable footerListenable =
      FastRefreshStateListenable();

  int refreshCount = 0;
  int loadCount = 0;
  Completer<FastRefreshResult>? refreshCompleter;
  Completer<FastRefreshResult>? loadCompleter;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    headerListenable.dispose();
    footerListenable.dispose();
    super.dispose();
  }

  Future<FastRefreshResult> _onRefresh() async {
    refreshCount += 1;
    refreshCompleter ??= Completer<FastRefreshResult>();
    return refreshCompleter!.future;
  }

  Future<FastRefreshResult> _onLoad() async {
    loadCount += 1;
    loadCompleter ??= Completer<FastRefreshResult>();
    return loadCompleter!.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          controller: controller,
          scrollController: scrollController,
          header: FastBuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(
                width: state.offset,
                height: double.infinity,
                child: Text(
                  'header:${state.mode.name}',
                  key: const Key('header-debug'),
                ),
              );
            },
          ),
          footer: FastBuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            infiniteOffset: null,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(
                width: state.offset,
                height: double.infinity,
                child: Text(
                  'footer:${state.mode.name}',
                  key: const Key('footer-debug'),
                ),
              );
            },
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemExtent: 100,
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                width: 100,
                child: Text('item $index'),
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpFuture(
  WidgetTester tester,
  Future<void> future, {
  Duration duration = const Duration(milliseconds: 400),
}) async {
  await tester.pump();
  await tester.pump(duration);
  await future;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _disposeHarness(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('horizontal ListView mounts', (WidgetTester tester) async {
    await tester.pumpWidget(const _HorizontalHarness());
    await tester.pump();

    expect(find.byType(FastRefresh), findsOneWidget);
    final ListView listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.scrollDirection, Axis.horizontal);

    await _disposeHarness(tester);
  });

  testWidgets('horizontal drag records axis and leaves inactive',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _HorizontalHarness());
    await tester.pump();

    final _HorizontalHarnessState state = tester.state<_HorizontalHarnessState>(
      find.byType(_HorizontalHarness),
    );

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable)),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(state.headerListenable.value, isNotNull);
    expect(state.headerListenable.value!.axis, Axis.horizontal);
    expect(
      state.headerListenable.value!.mode,
      isNot(FastRefreshMode.inactive),
    );

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    state.refreshCompleter?.complete(FastRefreshResult.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _disposeHarness(tester);
  });

  testWidgets('callRefresh runs onRefresh on a horizontal list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _HorizontalHarness());
    await tester.pump();

    final _HorizontalHarnessState state = tester.state<_HorizontalHarnessState>(
      find.byType(_HorizontalHarness),
    );
    await _pumpFuture(tester, state.controller.callRefresh());
    expect(state.refreshCount, 1);
    expect(state.headerListenable.value?.mode, FastRefreshMode.processing);

    state.refreshCompleter?.complete(FastRefreshResult.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _disposeHarness(tester);
  });

  testWidgets('callLoad runs onLoad on a horizontal list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _HorizontalHarness());
    await tester.pump();

    final _HorizontalHarnessState state = tester.state<_HorizontalHarnessState>(
      find.byType(_HorizontalHarness),
    );
    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 1);
    expect(state.footerListenable.value?.mode, FastRefreshMode.processing);

    state.loadCompleter?.complete(FastRefreshResult.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _disposeHarness(tester);
  });

  testWidgets('Classic header builds with a horizontal ListView',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            header: const FastClassicHeader(),
            footer: const FastClassicFooter(infiniteOffset: null),
            onRefresh: () async {},
            onLoad: () async {},
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemExtent: 100,
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(width: 100, child: Text('item $index'));
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FastRefresh), findsOneWidget);
    expect(
      tester.widget<ListView>(find.byType(ListView)).scrollDirection,
      Axis.horizontal,
    );
    await _disposeHarness(tester);
  });
}
