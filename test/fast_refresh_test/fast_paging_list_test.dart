import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PagingListHarness extends StatefulWidget {
  const _PagingListHarness({
    super.key,
    required this.fetchPage,
    this.header,
    this.refreshOnStart = true,
  });

  final FastPagingFetch<String> fetchPage;
  final FastRefreshHeader? header;
  final bool refreshOnStart;

  @override
  State<_PagingListHarness> createState() => _PagingListHarnessState();
}

class _PagingListHarnessState extends State<_PagingListHarness> {
  final FastRefreshController controller = FastRefreshController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FastPagingList<String>(
          controller: controller,
          refreshOnStart: widget.refreshOnStart,
          header: widget.header ??
              FastBuilderHeader(
                triggerOffset: 70,
                processedDuration: Duration.zero,
                safeArea: false,
                builder:
                    (BuildContext context, FastRefreshIndicatorState state) {
                  return SizedBox(height: state.offset);
                },
              ),
          footer: FastBuilderFooter(
            triggerOffset: 70,
            processedDuration: Duration.zero,
            safeArea: false,
            infiniteOffset: null,
            builder: (BuildContext context, FastRefreshIndicatorState state) {
              return SizedBox(height: state.offset);
            },
          ),
          fetchPage: widget.fetchPage,
          itemBuilder: (BuildContext context, int index, String item) {
            return SizedBox(
              height: 80,
              child: Text(item, key: Key('item-$index')),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() done, {
  int frames = 80,
}) async {
  for (int i = 0; i < frames && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _pumpCall(WidgetTester tester, Future<void> future) async {
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

void main() {
  testWidgets('first page and load more before total',
      (WidgetTester tester) async {
    final List<int> requested = <int>[];
    final GlobalKey<_PagingListHarnessState> key =
        GlobalKey<_PagingListHarnessState>();

    await tester.pumpWidget(_PagingListHarness(
      key: key,
      fetchPage: (int page) async {
        requested.add(page);
        return FastPagingPage<String>(
          page: page,
          total: 25,
          items: List<String>.generate(
            10,
            (int i) => 'Item ${(page - 1) * 10 + i}',
          ),
        );
      },
    ));

    await _waitUntil(tester, () => requested.isNotEmpty);
    await _settle(tester);
    await _waitUntil(
      tester,
      () => key.currentState!.controller.headerState?.mode ==
          FastRefreshMode.inactive,
    );
    expect(requested, <int>[1]);
    expect(find.byKey(const Key('item-0')), findsOneWidget);
    expect(find.byKey(const Key('item-10')), findsNothing);
    expect(
      key.currentState!.controller.footerState?.result,
      isNot(FastRefreshResult.noMore),
    );

    await _pumpCall(tester, key.currentState!.controller.callLoad());
    await _waitUntil(tester, () => requested.length >= 2);
    await _settle(tester);

    expect(requested, <int>[1, 2]);
    expect(find.byKey(const Key('item-10')), findsOneWidget);
    expect(
      key.currentState!.controller.footerState?.result,
      isNot(FastRefreshResult.noMore),
    );
  });

  testWidgets('total reached marks noMore', (WidgetTester tester) async {
    final GlobalKey<_PagingListHarnessState> key =
        GlobalKey<_PagingListHarnessState>();

    await tester.pumpWidget(_PagingListHarness(
      key: key,
      fetchPage: (int page) async {
        return FastPagingPage<String>(
          page: page,
          total: 10,
          items: List<String>.generate(10, (int i) => 'Item $i'),
        );
      },
    ));

    await _waitUntil(
      tester,
      () => find.byKey(const Key('item-0')).evaluate().isNotEmpty,
    );
    await _settle(tester);
    await _waitUntil(
      tester,
      () => key.currentState!.controller.headerState?.mode ==
          FastRefreshMode.inactive,
    );

    expect(
      key.currentState!.controller.footerState?.result,
      FastRefreshResult.noMore,
    );
  });

  testWidgets('empty page marks noMore', (WidgetTester tester) async {
    final GlobalKey<_PagingListHarnessState> key =
        GlobalKey<_PagingListHarnessState>();

    await tester.pumpWidget(_PagingListHarness(
      key: key,
      fetchPage: (int page) async {
        return const FastPagingPage<String>(
          page: 1,
          items: <String>[],
        );
      },
    ));

    await _waitUntil(
      tester,
      () => key.currentState!.controller.headerState?.mode ==
              FastRefreshMode.inactive ||
          key.currentState!.controller.footerState?.result ==
              FastRefreshResult.noMore,
    );
    await _settle(tester);
    await _waitUntil(
      tester,
      () => key.currentState!.controller.footerState?.result ==
          FastRefreshResult.noMore,
    );

    expect(find.byKey(const Key('item-0')), findsNothing);
    expect(
      key.currentState!.controller.footerState?.result,
      FastRefreshResult.noMore,
    );
  });

  testWidgets('fetch error keeps previous items and fails',
      (WidgetTester tester) async {
    final GlobalKey<_PagingListHarnessState> key =
        GlobalKey<_PagingListHarnessState>();
    int calls = 0;

    await tester.pumpWidget(_PagingListHarness(
      key: key,
      fetchPage: (int page) async {
        calls += 1;
        if (calls == 1) {
          return FastPagingPage<String>(
            page: 1,
            total: 20,
            items: List<String>.generate(10, (int i) => 'Item $i'),
          );
        }
        throw StateError('network');
      },
    ));

    await _waitUntil(
      tester,
      () => find.byKey(const Key('item-0')).evaluate().isNotEmpty,
    );
    await _settle(tester);
    await _waitUntil(
      tester,
      () => key.currentState!.controller.headerState?.mode ==
          FastRefreshMode.inactive,
    );

    await _pumpCall(tester, key.currentState!.controller.callRefresh());
    await _settle(tester);

    expect(find.byKey(const Key('item-0')), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('header override uses Material without a subclass',
      (WidgetTester tester) async {
    final GlobalKey<_PagingListHarnessState> key =
        GlobalKey<_PagingListHarnessState>();

    await tester.pumpWidget(_PagingListHarness(
      key: key,
      header: const FastMaterialHeader(safeArea: false),
      fetchPage: (int page) async {
        return const FastPagingPage<String>(
          page: 1,
          total: 5,
          items: <String>['A', 'B'],
        );
      },
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _waitUntil(
      tester,
      () => key.currentState!.controller.headerState?.mode ==
          FastRefreshMode.processing,
    );

    expect(find.byType(RefreshProgressIndicator), findsWidgets);
    expect(find.byType(FastPagingList<String>), findsOneWidget);
  });
}
