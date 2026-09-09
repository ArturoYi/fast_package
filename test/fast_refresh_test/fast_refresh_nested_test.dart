import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _NestedHarness extends StatefulWidget {
  const _NestedHarness();

  @override
  State<_NestedHarness> createState() => _NestedHarnessState();
}

class _NestedHarnessState extends State<_NestedHarness> {
  final FastRefreshController controller = FastRefreshController();
  final FastRefreshStateListenable headerListenable =
      FastRefreshStateListenable();

  ScrollController? innerController;
  int refreshCount = 0;
  Completer<FastRefreshResult>? refreshCompleter;

  @override
  void dispose() {
    controller.dispose();
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
        body: NestedScrollView(
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                pinned: true,
                title: Text('Nested'),
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              innerController = PrimaryScrollController.of(context);
              return FastRefresh.builder(
                controller: controller,
                scrollController: innerController,
                isNested: true,
                header: FastBuilderHeader(
                  listenable: headerListenable,
                  triggerOffset: 70,
                  processedDuration: Duration.zero,
                  safeArea: false,
                  builder:
                      (BuildContext context, FastRefreshIndicatorState state) {
                    return SizedBox(height: state.offset);
                  },
                ),
                onRefresh: _onRefresh,
                childBuilder: (BuildContext context, ScrollPhysics physics) {
                  return ListView.builder(
                    physics: physics,
                    itemCount: 30,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 80,
                        child: Text('item $index'),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'isNested NestedScrollView mounts and callRefresh starts onRefresh',
    (WidgetTester tester) async {
      await tester.pumpWidget(const _NestedHarness());
      await tester.pump();

      expect(find.byType(FastRefresh), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);

      final _NestedHarnessState state = tester.state<_NestedHarnessState>(
        find.byType(_NestedHarness),
      );
      // Nested 内层要先有一次滚动，physics 才会写入 ScrollPosition。
      await tester.drag(find.byType(ListView), const Offset(0, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      unawaited(
        state.controller.callRefresh(scrollController: state.innerController),
      );
      for (int i = 0; i < 50 && state.refreshCount == 0; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

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
    },
  );
}
