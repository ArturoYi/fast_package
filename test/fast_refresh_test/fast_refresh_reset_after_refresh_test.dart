import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResetHarness extends StatefulWidget {
  const _ResetHarness({
    this.controlFinishRefresh = false,
    this.refreshResult = FastRefreshResult.success,
    this.refreshThrows = false,
  });

  final bool controlFinishRefresh;
  final FastRefreshResult refreshResult;
  final bool refreshThrows;

  @override
  State<_ResetHarness> createState() => _ResetHarnessState();
}

class _ResetHarnessState extends State<_ResetHarness> {
  late final FastRefreshController controller;
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable footerListenable =
      FastRefreshStateListenable();

  Completer<FastRefreshResult>? refreshCompleter;
  int loadCount = 0;

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
    footerListenable.dispose();
    super.dispose();
  }

  Future<FastRefreshResult?> _onRefresh() async {
    if (widget.controlFinishRefresh) {
      return null;
    }
    if (widget.refreshThrows) {
      throw StateError('refresh failed');
    }
    refreshCompleter ??= Completer<FastRefreshResult>();
    return refreshCompleter!.future;
  }

  Future<FastRefreshResult> _onLoad() async {
    loadCount += 1;
    return FastRefreshResult.noMore;
  }

  void completeRefresh([FastRefreshResult? result]) {
    if (widget.controlFinishRefresh) {
      controller.finishRefresh(result ?? widget.refreshResult);
      return;
    }
    refreshCompleter?.complete(result ?? widget.refreshResult);
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
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(height: state.offset);
            },
          ),
          footer: FastBuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            infiniteOffset: null,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(height: state.offset);
            },
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemCount: 30,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(height: 80, child: Text('item $index'));
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpCall(
  WidgetTester tester,
  Future<void> future,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await future;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<_ResetHarnessState> _lockFooterNoMore(WidgetTester tester) async {
  final _ResetHarnessState state = tester.state<_ResetHarnessState>(
    find.byType(_ResetHarness),
  );
  await _pumpCall(tester, state.controller.callLoad());
  await _settle(tester);
  expect(state.footerListenable.value?.result, FastRefreshResult.noMore);
  return state;
}

void main() {
  testWidgets('successful refresh clears footer noMore',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _ResetHarness());
    await tester.pump();
    final _ResetHarnessState state = await _lockFooterNoMore(tester);

    await _pumpCall(tester, state.controller.callRefresh());
    state.completeRefresh(FastRefreshResult.success);
    await _settle(tester);

    expect(state.footerListenable.value?.result, isNot(FastRefreshResult.noMore));
    await _pumpCall(tester, state.controller.callLoad());
    expect(state.loadCount, 2);
  });

  testWidgets('failed refresh keeps footer noMore', (WidgetTester tester) async {
    await tester.pumpWidget(const _ResetHarness(
      refreshResult: FastRefreshResult.fail,
    ));
    await tester.pump();
    final _ResetHarnessState state = await _lockFooterNoMore(tester);

    await _pumpCall(tester, state.controller.callRefresh());
    state.completeRefresh(FastRefreshResult.fail);
    await _settle(tester);

    expect(state.footerListenable.value?.result, FastRefreshResult.noMore);
    await _pumpCall(tester, state.controller.callLoad());
    expect(state.loadCount, 1);
  });

  testWidgets('thrown refresh keeps footer noMore', (WidgetTester tester) async {
    await tester.pumpWidget(const _ResetHarness(refreshThrows: true));
    await tester.pump();
    final _ResetHarnessState state = await _lockFooterNoMore(tester);

    await _pumpCall(tester, state.controller.callRefresh());
    await _settle(tester);

    expect(state.footerListenable.value?.result, FastRefreshResult.noMore);
  });

  testWidgets('finishRefresh success resets footer noMore',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _ResetHarness(controlFinishRefresh: true));
    await tester.pump();
    final _ResetHarnessState state = await _lockFooterNoMore(tester);

    await _pumpCall(tester, state.controller.callRefresh());
    state.completeRefresh(FastRefreshResult.success);
    await _settle(tester);

    expect(state.footerListenable.value?.result, isNot(FastRefreshResult.noMore));
  });

  testWidgets('finishRefresh fail keeps footer noMore',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _ResetHarness(controlFinishRefresh: true));
    await tester.pump();
    final _ResetHarnessState state = await _lockFooterNoMore(tester);

    await _pumpCall(tester, state.controller.callRefresh());
    state.completeRefresh(FastRefreshResult.fail);
    await _settle(tester);

    expect(state.footerListenable.value?.result, FastRefreshResult.noMore);
  });
}
