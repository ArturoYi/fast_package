import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SecondaryHarness extends StatefulWidget {
  const _SecondaryHarness({this.secondaryTriggerOffset = 120});

  final double? secondaryTriggerOffset;

  @override
  State<_SecondaryHarness> createState() => _SecondaryHarnessState();
}

class _SecondaryHarnessState extends State<_SecondaryHarness> {
  final FastRefreshController controller = FastRefreshController();
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable headerListenable =
      FastRefreshStateListenable();

  int refreshCount = 0;
  Completer<FastRefreshResult>? refreshCompleter;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    headerListenable.dispose();
    super.dispose();
  }

  Future<FastRefreshResult> _onRefresh() async {
    refreshCount += 1;
    refreshCompleter ??= Completer<FastRefreshResult>();
    return refreshCompleter!.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          clipBehavior: Clip.none,
          controller: controller,
          scrollController: scrollController,
          header: FastBuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            secondaryTriggerOffset: widget.secondaryTriggerOffset,
            secondaryDimension: 400,
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
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: scrollController,
            itemCount: 20,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(height: 80, child: Text('item $index'));
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpOpenClose(
  WidgetTester tester,
  Future<void> future,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await future;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _disposeHarness(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('openHeaderSecondary then closeHeaderSecondary',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _SecondaryHarness());
    await tester.pump();

    final _SecondaryHarnessState state = tester.state<_SecondaryHarnessState>(
      find.byType(_SecondaryHarness),
    );

    await _pumpOpenClose(tester, state.controller.openHeaderSecondary());
    expect(
      state.headerListenable.value?.mode,
      FastRefreshMode.secondaryOpen,
    );
    expect(state.refreshCount, 0);

    await _pumpOpenClose(tester, state.controller.closeHeaderSecondary());
    expect(state.headerListenable.value?.mode, FastRefreshMode.inactive);
    expect(state.headerListenable.value?.offset, 0);

    await _disposeHarness(tester);
  });

  testWidgets('openHeaderSecondary is a no-op without secondaryTriggerOffset',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const _SecondaryHarness(secondaryTriggerOffset: null),
    );
    await tester.pump();

    final _SecondaryHarnessState state = tester.state<_SecondaryHarnessState>(
      find.byType(_SecondaryHarness),
    );

    await _pumpOpenClose(tester, state.controller.openHeaderSecondary());
    expect(
      state.headerListenable.value?.mode,
      isNot(FastRefreshMode.secondaryOpen),
    );
    expect(state.refreshCount, 0);

    await _disposeHarness(tester);
  });

  testWidgets('pull past secondary trigger opens the second floor',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _SecondaryHarness());
    await tester.pump();

    final _SecondaryHarnessState state = tester.state<_SecondaryHarnessState>(
      find.byType(_SecondaryHarness),
    );

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable)),
    );
    await gesture.moveBy(const Offset(0, 200));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 200));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 200));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      state.headerListenable.value?.mode,
      isIn(<FastRefreshMode>[
        FastRefreshMode.secondaryReady,
        FastRefreshMode.secondaryOpen,
      ]),
    );
    expect(state.refreshCount, 0);

    if (state.headerListenable.value?.mode == FastRefreshMode.secondaryOpen) {
      await _pumpOpenClose(tester, state.controller.closeHeaderSecondary());
    }
    state.refreshCompleter?.complete(FastRefreshResult.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _disposeHarness(tester);
  });
}
