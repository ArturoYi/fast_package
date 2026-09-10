import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestItem {
  const _TestItem({required this.id, required this.name});

  final int id;
  final String name;
}

class _TestData {
  const _TestData({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPage,
  });

  final List<_TestItem> items;
  final int total;
  final int page;
  final int totalPage;
}

class _TestFastPaging extends FastPaging<_TestData, _TestItem> {
  const _TestFastPaging({
    super.controller,
    super.useDefaultPhysics,
    super.refreshOnStart,
    super.emptyWidgetBuilder,
    super.itemBuilder,
    this.itemsPerPage = 10,
    this.maxPages = 3,
    this.onRefreshCallback,
    this.onLoadCallback,
    this.enableRefreshOverride = true,
    this.enableLoadOverride = true,
  });

  final int itemsPerPage;
  final int maxPages;
  final Future<void> Function()? onRefreshCallback;
  final Future<void> Function()? onLoadCallback;
  final bool enableRefreshOverride;
  final bool enableLoadOverride;

  @override
  FastPagingState<_TestData, _TestItem, _TestFastPaging> createState() =>
      _TestFastPagingState();
}

class _TestFastPagingState
    extends FastPagingState<_TestData, _TestItem, _TestFastPaging> {
  @override
  bool get enableRefresh => widget.enableRefreshOverride;

  @override
  bool get enableLoad => widget.enableLoadOverride;

  @override
  int? get totalPage => data?.totalPage;

  @override
  int? get page => data?.page;

  @override
  int? get total => data?.total;

  @override
  int get count => data?.items.length ?? 0;

  @override
  _TestItem getItem(int index) => data!.items[index];

  @override
  FastRefreshHeader buildHeader() {
    return FastBuilderHeader(
      triggerOffset: 70,
      processedDuration: Duration.zero,
      safeArea: false,
      builder: (BuildContext context, FastRefreshIndicatorState state) {
        return SizedBox(height: state.offset);
      },
    );
  }

  @override
  FastRefreshFooter buildFooter() {
    return FastBuilderFooter(
      triggerOffset: 70,
      processedDuration: Duration.zero,
      safeArea: false,
      infiniteOffset: null,
      builder: (BuildContext context, FastRefreshIndicatorState state) {
        return SizedBox(height: state.offset);
      },
    );
  }

  @override
  Future<FastRefreshResult?> onRefresh() async {
    await widget.onRefreshCallback?.call();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    setState(() {
      data = _TestData(
        items: List<_TestItem>.generate(
          widget.itemsPerPage,
          (int i) => _TestItem(id: i, name: 'Item $i'),
        ),
        total: widget.itemsPerPage * widget.maxPages,
        page: 1,
        totalPage: widget.maxPages,
      );
    });
    return null;
  }

  @override
  Future<FastRefreshResult?> onLoad() async {
    await widget.onLoadCallback?.call();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (data == null) {
      return null;
    }
    final int currentPage = data!.page;
    if (currentPage >= data!.totalPage) {
      return FastRefreshResult.noMore;
    }
    final List<_TestItem> newItems = List<_TestItem>.generate(
      widget.itemsPerPage,
      (int i) => _TestItem(
        id: currentPage * widget.itemsPerPage + i,
        name: 'Item ${currentPage * widget.itemsPerPage + i}',
      ),
    );
    setState(() {
      data = _TestData(
        items: <_TestItem>[...data!.items, ...newItems],
        total: data!.total,
        page: currentPage + 1,
        totalPage: data!.totalPage,
      );
    });
    return null;
  }

  @override
  Widget buildItem(BuildContext context, int index, _TestItem item) {
    if (widget.itemBuilder != null) {
      return buildItemByBuilder(context, index, item);
    }
    return SizedBox(
      key: Key('paging-item-${item.id}'),
      height: 80,
      child: Text(item.name),
    );
  }
}

class _PagingHarness extends StatefulWidget {
  const _PagingHarness({
    super.key,
    this.itemsPerPage = 10,
    this.maxPages = 3,
    this.refreshOnStart = false,
    this.useDefaultPhysics = false,
    this.enableRefresh = true,
    this.enableLoad = true,
  });

  final int itemsPerPage;
  final int maxPages;
  final bool refreshOnStart;
  final bool useDefaultPhysics;
  final bool enableRefresh;
  final bool enableLoad;

  @override
  State<_PagingHarness> createState() => _PagingHarnessState();
}

class _PagingHarnessState extends State<_PagingHarness> {
  late final FastRefreshController controller;

  int refreshCallCount = 0;
  int loadCallCount = 0;

  @override
  void initState() {
    super.initState();
    controller = FastRefreshController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _TestFastPaging(
          controller: controller,
          useDefaultPhysics: widget.useDefaultPhysics,
          itemsPerPage: widget.itemsPerPage,
          maxPages: widget.maxPages,
          enableRefreshOverride: widget.enableRefresh,
          enableLoadOverride: widget.enableLoad,
          refreshOnStart: widget.refreshOnStart,
          onRefreshCallback: () async {
            refreshCallCount += 1;
          },
          onLoadCallback: () async {
            loadCallCount += 1;
          },
        ),
      ),
    );
  }
}

Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() done, {
  int frames = 50,
}) async {
  for (int i = 0; i < frames && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 20));
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

Future<void> _settleFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('FastPaging', () {
    testWidgets('renders and refreshOnStart loads the first page',
        (WidgetTester tester) async {
      final GlobalKey<_PagingHarnessState> key =
          GlobalKey<_PagingHarnessState>();
      await tester.pumpWidget(_PagingHarness(
        key: key,
        refreshOnStart: true,
      ));
      final _PagingHarnessState state = key.currentState!;

      await _waitUntil(tester, () => state.refreshCallCount > 0);
      expect(state.refreshCallCount, 1);

      await _settleFrames(tester);
      expect(find.byKey(const Key('paging-item-0')), findsOneWidget);

      final _TestFastPagingState pagingState =
          tester.state<_TestFastPagingState>(
        find.byType(_TestFastPaging),
      );
      expect(pagingState.page, 1);
      expect(pagingState.totalPage, 3);
      expect(pagingState.total, 30);
      expect(pagingState.count, 10);
      expect(pagingState.getItem(0).name, 'Item 0');
      expect(pagingState.isNoMore, isFalse);
    });

    testWidgets('callLoad appends pages and isNoMore becomes true',
        (WidgetTester tester) async {
      final GlobalKey<_PagingHarnessState> key =
          GlobalKey<_PagingHarnessState>();
      await tester.pumpWidget(_PagingHarness(
        key: key,
        refreshOnStart: true,
        itemsPerPage: 10,
        maxPages: 2,
      ));
      final _PagingHarnessState state = key.currentState!;

      await _waitUntil(tester, () => state.refreshCallCount > 0);
      await _settleFrames(tester);
      await _waitUntil(
        tester,
        () => state.controller.headerState?.mode == FastRefreshMode.inactive,
      );

      final _TestFastPagingState pagingState =
          tester.state<_TestFastPagingState>(
        find.byType(_TestFastPaging),
      );
      expect(pagingState.isNoMore, isFalse);

      await _pumpFuture(tester, state.controller.callLoad());
      await _waitUntil(tester, () => state.loadCallCount > 0);
      await _settleFrames(tester);

      expect(pagingState.page, 2);
      expect(pagingState.count, 20);
      expect(pagingState.isNoMore, isTrue);
      expect(find.byKey(const Key('paging-item-10')), findsOneWidget);
    });

    testWidgets('enableRefresh false skips refreshOnStart',
        (WidgetTester tester) async {
      final GlobalKey<_PagingHarnessState> key =
          GlobalKey<_PagingHarnessState>();
      await tester.pumpWidget(_PagingHarness(
        key: key,
        refreshOnStart: true,
        enableRefresh: false,
      ));
      final _PagingHarnessState state = key.currentState!;

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(state.refreshCallCount, 0);
    });

    testWidgets('enableLoad false ignores callLoad',
        (WidgetTester tester) async {
      final GlobalKey<_PagingHarnessState> key =
          GlobalKey<_PagingHarnessState>();
      await tester.pumpWidget(_PagingHarness(
        key: key,
        refreshOnStart: true,
        enableLoad: false,
      ));
      final _PagingHarnessState state = key.currentState!;

      await _waitUntil(tester, () => state.refreshCallCount > 0);
      await _settleFrames(tester);

      await _pumpFuture(tester, state.controller.callLoad());
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(state.loadCallCount, 0);
    });

    testWidgets('useDefaultPhysics still builds FastRefresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(const _PagingHarness(
        refreshOnStart: true,
        useDefaultPhysics: true,
      ));
      await _settleFrames(tester);
      expect(find.byType(_TestFastPaging), findsOneWidget);
      expect(find.byType(FastRefresh), findsOneWidget);
    });

    testWidgets('emptyWidget shows when the first page is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestFastPaging(
            itemsPerPage: 0,
            maxPages: 1,
            refreshOnStart: true,
            emptyWidgetBuilder: (BuildContext context) {
              return const Text('No data available', key: Key('empty-widget'));
            },
          ),
        ),
      ));

      await tester.pump();
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      await _settleFrames(tester);

      expect(find.byKey(const Key('empty-widget')), findsOneWidget);
    });

    testWidgets('itemBuilder is used when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _TestFastPaging(
            refreshOnStart: true,
            itemsPerPage: 5,
            itemBuilder: (BuildContext context, int index, _TestItem item) {
              return SizedBox(
                key: Key('custom-item-${item.id}'),
                height: 48,
                child: Text('Custom: ${item.name}'),
              );
            },
          ),
        ),
      ));

      await _waitUntil(
        tester,
        () => tester.any(find.byKey(const Key('custom-item-0'))),
      );
      await _settleFrames(tester);
      expect(find.byKey(const Key('custom-item-0')), findsOneWidget);
      expect(find.text('Custom: Item 0'), findsOneWidget);
    });
  });
}
