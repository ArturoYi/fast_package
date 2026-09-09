import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LocatorHarness extends StatefulWidget {
  const _LocatorHarness();

  @override
  State<_LocatorHarness> createState() => _LocatorHarnessState();
}

class _LocatorHarnessState extends State<_LocatorHarness> {
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
          controller: controller,
          scrollController: scrollController,
          header: FastBuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            position: FastRefreshIndicatorPosition.locator,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(
                height: state.offset,
                child: Text(
                  'header:${state.mode.name}',
                  key: const Key('locator-header'),
                ),
              );
            },
          ),
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              const FastHeaderLocator.sliver(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return SizedBox(height: 80, child: Text('item $index'));
                  },
                  childCount: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('locator sliver updates header mode on callRefresh',
      (WidgetTester tester) async {
    await tester.pumpWidget(const _LocatorHarness());
    await tester.pump();

    expect(find.byType(FastHeaderLocator), findsOneWidget);

    final _LocatorHarnessState state = tester.state<_LocatorHarnessState>(
      find.byType(_LocatorHarness),
    );
    final Future<void> refresh = state.controller.callRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await refresh;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(state.refreshCount, 1);
    expect(
      state.headerListenable.value?.mode,
      FastRefreshMode.processing,
    );

    state.refreshCompleter?.complete(FastRefreshResult.success);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
