
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _OnStartHarness extends StatefulWidget {
  const _OnStartHarness();

  @override
  State<_OnStartHarness> createState() => _OnStartHarnessState();
}

class _OnStartHarnessState extends State<_OnStartHarness> {
  final FastRefreshController controller = FastRefreshController(
    controlFinishRefresh: true,
  );
  final ScrollController scrollController = ScrollController();

  int refreshCount = 0;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    refreshCount += 1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          controller: controller,
          scrollController: scrollController,
          refreshOnStart: true,
          header: FastBuilderHeader(
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

void main() {
  testWidgets('refreshOnStart fires once after first frame',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _OnStartHarness());
    final _OnStartHarnessState state = tester.state<_OnStartHarnessState>(
      find.byType(_OnStartHarness),
    );

    for (int i = 0; i < 50 && state.refreshCount == 0; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(state.refreshCount, 1);

    state.controller.finishRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final Future<void> refresh = state.controller.callRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await refresh;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(state.refreshCount, 2);
    state.controller.finishRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
