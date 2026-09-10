import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SwapHost extends StatefulWidget {
  const _SwapHost();

  @override
  State<_SwapHost> createState() => _SwapHostState();
}

class _SwapHostState extends State<_SwapHost> {
  final FastRefreshController controllerA = FastRefreshController();
  final FastRefreshController controllerB = FastRefreshController();
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable headerListenable =
      FastRefreshStateListenable();

  late FastRefreshController current;
  int refreshCount = 0;

  @override
  void initState() {
    super.initState();
    current = controllerA;
  }

  void useB() {
    setState(() {
      current = controllerB;
    });
  }

  @override
  void dispose() {
    controllerA.dispose();
    controllerB.dispose();
    scrollController.dispose();
    headerListenable.dispose();
    super.dispose();
  }

  Future<FastRefreshResult> _onRefresh() async {
    refreshCount += 1;
    return FastRefreshResult.success;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          controller: current,
          scrollController: scrollController,
          header: FastBuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(height: state.offset);
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

Future<void> _pumpCallRefresh(
  WidgetTester tester,
  Future<void> future,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await future;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('finishRefresh and callRefresh after dispose are no-ops',
      (WidgetTester tester) async {
    final FastRefreshController controller = FastRefreshController(
      controlFinishRefresh: true,
    );
    final ScrollController scrollController = ScrollController();
    int refreshCount = 0;
    addTearDown(() {
      controller.dispose();
      scrollController.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            controller: controller,
            scrollController: scrollController,
            header: FastBuilderHeader(
              triggerOffset: 70,
              processedDuration: Duration.zero,
              safeArea: false,
              builder:
                  (BuildContext context, FastRefreshIndicatorState state) {
                return SizedBox(height: state.offset);
              },
            ),
            onRefresh: () async {
              refreshCount += 1;
            },
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
    await tester.pump(Duration.zero);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(Duration.zero);

    expect(() => controller.finishRefresh(), returnsNormally);
    await expectLater(controller.callRefresh(), completes);
    expect(refreshCount, 0);
    expect(controller.headerState, isNull);
  });

  testWidgets('replacing controller unbinds the previous one',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _SwapHost());
    await tester.pump();

    final _SwapHostState state = tester.state<_SwapHostState>(
      find.byType(_SwapHost),
    );
    state.useB();
    await tester.pump();

    await _pumpCallRefresh(tester, state.controllerA.callRefresh());
    expect(state.refreshCount, 0);
    expect(state.controllerA.headerState, isNull);

    await _pumpCallRefresh(tester, state.controllerB.callRefresh());
    expect(state.refreshCount, 1);
    expect(
      state.headerListenable.value?.mode,
      isIn(<FastRefreshMode>[
        FastRefreshMode.processing,
        FastRefreshMode.processed,
        FastRefreshMode.done,
        FastRefreshMode.inactive,
      ]),
    );
  });
}
