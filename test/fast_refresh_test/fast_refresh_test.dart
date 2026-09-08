import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness extends StatefulWidget {
  const _Harness({
    this.controlFinishRefresh = false,
    this.onRefreshEnabled = true,
    this.onLoadEnabled = true,
    this.footerInfiniteOffset = 70,
  });

  final bool controlFinishRefresh;
  final bool onRefreshEnabled;
  final bool onLoadEnabled;
  final double? footerInfiniteOffset;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late final FastRefreshController controller;
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable headerListenable =
      FastRefreshStateListenable();
  final FastRefreshStateListenable footerListenable =
      FastRefreshStateListenable();

  int refreshCount = 0;
  int loadCount = 0;
  FastRefreshResult? lastRefreshResult;
  FastRefreshResult? lastLoadResult;
  Completer<FastRefreshResult>? refreshCompleter;
  Completer<FastRefreshResult>? loadCompleter;

  @override
  void initState() {
    super.initState();
    controller = FastRefreshController(
      controlFinishRefresh: widget.controlFinishRefresh,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    headerListenable.dispose();
    footerListenable.dispose();
    super.dispose();
  }

  Future<FastRefreshResult?> _onRefresh() async {
    refreshCount += 1;
    if (widget.controlFinishRefresh) {
      return null;
    }
    refreshCompleter ??= Completer<FastRefreshResult>();
    final FastRefreshResult result = await refreshCompleter!.future;
    lastRefreshResult = result;
    refreshCompleter = null;
    return result;
  }

  Future<FastRefreshResult?> _onLoad() async {
    loadCount += 1;
    loadCompleter ??= Completer<FastRefreshResult>();
    final FastRefreshResult result = await loadCompleter!.future;
    lastLoadResult = result;
    loadCompleter = null;
    return result;
  }

  void completeRefresh([
    FastRefreshResult result = FastRefreshResult.success,
  ]) {
    if (widget.controlFinishRefresh) {
      controller.finishRefresh(result);
      return;
    }
    refreshCompleter?.complete(result);
  }

  void completeLoad([FastRefreshResult result = FastRefreshResult.success]) {
    loadCompleter?.complete(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          controller: controller,
          scrollController: scrollController,
          resetAfterRefresh: true,
          header: FastBuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(
                height: state.offset,
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
            infiniteOffset: widget.footerInfiniteOffset,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(
                height: state.offset,
                child: Text(
                  'footer:${state.mode.name}',
                  key: const Key('footer-debug'),
                ),
              );
            },
          ),
          onRefresh: widget.onRefreshEnabled ? _onRefresh : null,
          onLoad: widget.onLoadEnabled ? _onLoad : null,
          child: ListView.builder(
            controller: scrollController,
            itemCount: 30,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 80,
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
  // Programmatic trigger animates past the threshold, then the ready
  // spring settles on actualTriggerOffset and starts the task.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _settleSpring(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('callRefresh runs onRefresh and returns to inactive',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _Harness(onLoadEnabled: false));
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callRefresh());
    expect(state.refreshCount, 1);
    expect(state.headerListenable.value?.mode, FastRefreshMode.processing);

    state.completeRefresh();
    await _settleSpring(tester);
    expect(state.lastRefreshResult, FastRefreshResult.success);
    expect(
      state.headerListenable.value?.mode,
      isIn(<FastRefreshMode>[
        FastRefreshMode.done,
        FastRefreshMode.inactive,
      ]),
    );
  });

  testWidgets('release before trigger does not refresh',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _Harness(onLoadEnabled: false));
    await tester.pump();

    await tester.drag(find.byType(Scrollable), const Offset(0, 40));
    await _settleSpring(tester);

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    expect(state.refreshCount, 0);
  });

  testWidgets('null onRefresh disables refresh', (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(onRefreshEnabled: false, onLoadEnabled: false),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callRefresh());
    expect(state.refreshCount, 0);
  });

  testWidgets('callLoad runs onLoad', (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(
        onRefreshEnabled: false,
        footerInfiniteOffset: null,
      ),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(
      tester,
      state.controller.callLoad(),
      duration: const Duration(milliseconds: 400),
    );
    expect(state.loadCount, 1);
    expect(state.footerListenable.value?.mode, FastRefreshMode.processing);

    state.completeLoad();
    await _settleSpring(tester);
    expect(state.lastLoadResult, FastRefreshResult.success);
  });

  testWidgets('approaching bottom starts load when infiniteOffset is set',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _Harness(onRefreshEnabled: false));
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(state.loadCount, greaterThanOrEqualTo(1));
  });

  testWidgets('null onLoad disables load', (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(onRefreshEnabled: false, onLoadEnabled: false),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 0);
  });

  testWidgets('callback throw becomes fail', (WidgetTester tester) async {
    final FastRefreshStateListenable listenable = FastRefreshStateListenable();
    FastRefreshResult? seenResult;
    listenable.addListener(() {
      final FastRefreshResult? result = listenable.value?.result;
      if (result != null && result != FastRefreshResult.none) {
        seenResult = result;
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        home: _ThrowRefreshApp(listenable: listenable),
      ),
    );
    await tester.pump();
    final FastRefreshController controller =
        tester.state<_ThrowRefreshAppState>(find.byType(_ThrowRefreshApp))
            .controller;
    await _pumpFuture(tester, controller.callRefresh());
    await _settleSpring(tester);
    expect(seenResult, FastRefreshResult.fail);
  });

  testWidgets('noMore locks further load until resetFooter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(
        onRefreshEnabled: false,
        footerInfiniteOffset: null,
      ),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callLoad());
    state.completeLoad(FastRefreshResult.noMore);
    await _settleSpring(tester);
    expect(state.lastLoadResult, FastRefreshResult.noMore);

    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 1);

    state.controller.resetFooter();
    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 2);
    state.completeLoad();
    await _settleSpring(tester);
  });

  testWidgets('finishRefresh completes a controlled refresh',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(
        controlFinishRefresh: true,
        onLoadEnabled: false,
      ),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callRefresh());
    expect(state.headerListenable.value?.mode, FastRefreshMode.processing);

    state.completeRefresh();
    await _settleSpring(tester);
    expect(
      state.headerListenable.value?.mode,
      isIn(<FastRefreshMode>[
        FastRefreshMode.done,
        FastRefreshMode.inactive,
      ]),
    );
  });

  testWidgets('refresh clears footer noMore when resetAfterRefresh is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(footerInfiniteOffset: null),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callLoad());
    state.completeLoad(FastRefreshResult.noMore);
    await _settleSpring(tester);

    await _pumpFuture(tester, state.controller.callRefresh());
    state.completeRefresh();
    await _settleSpring(tester);

    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 2);
    state.completeLoad();
    await _settleSpring(tester);
  });

  testWidgets('load is blocked while refresh is processing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const _Harness(
        controlFinishRefresh: true,
        footerInfiniteOffset: null,
      ),
    );
    await tester.pump();

    final _HarnessState state = tester.state<_HarnessState>(
      find.byType(_Harness),
    );
    await _pumpFuture(tester, state.controller.callRefresh());
    expect(state.headerListenable.value?.mode, FastRefreshMode.processing);

    await _pumpFuture(tester, state.controller.callLoad());
    expect(state.loadCount, 0);

    state.completeRefresh();
    await _settleSpring(tester);
  });

  testWidgets('FastRefresh.builder callRefresh runs onRefresh',
      (WidgetTester tester) async {
    final FastRefreshController controller = FastRefreshController();
    final ScrollController scrollController = ScrollController();
    final FastRefreshStateListenable headerListenable =
        FastRefreshStateListenable();
    int refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh.builder(
            controller: controller,
            scrollController: scrollController,
            header: FastBuilderHeader(
              listenable: headerListenable,
              triggerOffset: 70,
              processedDuration: Duration.zero,
              safeArea: false,
              builder: (BuildContext context, FastRefreshIndicatorState state) {
                return SizedBox(
                  height: state.offset,
                  child: Text(
                    'header:${state.mode.name}',
                    key: const Key('builder-header-debug'),
                  ),
                );
              },
            ),
            onRefresh: () async {
              refreshCount += 1;
              return FastRefreshResult.success;
            },
            childBuilder: (BuildContext context, ScrollPhysics physics) {
              return ListView.builder(
                controller: scrollController,
                physics: physics,
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 80, child: Text('item $index'));
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await _pumpFuture(tester, controller.callRefresh());
    expect(refreshCount, 1);
    expect(
      headerListenable.value?.mode,
      isIn(<FastRefreshMode>[
        FastRefreshMode.processing,
        FastRefreshMode.processed,
        FastRefreshMode.done,
        FastRefreshMode.inactive,
      ]),
    );
    await _settleSpring(tester);
    controller.dispose();
    scrollController.dispose();
    headerListenable.dispose();
  });

  testWidgets('classic header shows processing text',
      (WidgetTester tester) async {
    final FastRefreshController controller = FastRefreshController(
      controlFinishRefresh: true,
    );
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            controller: controller,
            scrollController: scrollController,
            header: const FastClassicHeader(
              processedDuration: Duration.zero,
              safeArea: false,
              showMessage: false,
              processingText: 'Refreshing...',
            ),
            onRefresh: () async {},
            child: ListView.builder(
              controller: scrollController,
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(height: 80, child: Text('item $index'));
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await _pumpFuture(tester, controller.callRefresh());
    expect(find.text('Refreshing...'), findsOneWidget);
    controller.finishRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    controller.dispose();
    scrollController.dispose();
  });
}

Widget _offsetBox(BuildContext context, FastRefreshIndicatorState state) {
  return SizedBox(height: state.offset);
}

class _ThrowRefreshApp extends StatefulWidget {
  const _ThrowRefreshApp({required this.listenable});

  final FastRefreshStateListenable listenable;

  @override
  State<_ThrowRefreshApp> createState() => _ThrowRefreshAppState();
}

class _ThrowRefreshAppState extends State<_ThrowRefreshApp> {
  final FastRefreshController controller = FastRefreshController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FastRefresh(
        controller: controller,
        scrollController: scrollController,
        header: FastBuilderHeader(
          listenable: widget.listenable,
          processedDuration: Duration.zero,
          safeArea: false,
          builder: _offsetBox,
        ),
        onRefresh: () async {
          throw StateError('refresh failed');
        },
        child: ListView.builder(
          controller: scrollController,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(height: 80, child: Text('item $index'));
          },
        ),
      ),
    );
  }
}
