import 'dart:async';

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoadHarness extends StatefulWidget {
  const _LoadHarness({super.key});

  @override
  State<_LoadHarness> createState() => _LoadHarnessState();
}

class _LoadHarnessState extends State<_LoadHarness> {
  final FastRefreshController controller = FastRefreshController(
    controlFinishLoad: true,
  );
  final ScrollController scrollController = ScrollController();
  final FastRefreshStateListenable footerListenable =
      FastRefreshStateListenable();

  int itemCount = 60;
  final Completer<void> loadStarted = Completer<void>();

  FastRefreshIndicatorState? get footerState => footerListenable.value;

  void appendItems([int delta = 200]) {
    setState(() {
      itemCount += delta;
    });
  }

  Future<void> _onLoad() async {
    if (!loadStarted.isCompleted) {
      loadStarted.complete();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    footerListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastRefresh(
          controller: controller,
          scrollController: scrollController,
          footer: FastBuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            infiniteOffset: null,
            triggerWhenRelease: true,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return Text(
                'footer:${state.mode.name}',
                key: const Key('footer-debug'),
              );
            },
          ),
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemExtent: 50,
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) {
              return Text('Item $index');
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _triggerBottomOverscrollLoad(
  WidgetTester tester,
  _LoadHarnessState state,
) async {
  await tester.pump();
  state.scrollController.jumpTo(state.scrollController.position.maxScrollExtent);
  await tester.pump();
  await tester.drag(find.byType(ListView), const Offset(0, -200));
  await tester.pump();
  await state.loadStarted.future.timeout(const Duration(seconds: 2));
  await tester.pump();
  expect(state.footerState, isNotNull);
  expect(state.footerState!.mode, FastRefreshMode.processing);
  expect(state.footerState!.offset, greaterThan(0));
}

void main() {
  testWidgets(
    'completion sync clears footer offset when list grows out of overscroll',
    (WidgetTester tester) async {
      final GlobalKey<_LoadHarnessState> key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(_LoadHarness(key: key));
      final _LoadHarnessState state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems();
      await tester.pump();

      state.controller.finishLoad();
      await tester.pump();
      await tester.pump();

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, FastRefreshMode.inactive);
      expect(state.footerState!.offset, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
