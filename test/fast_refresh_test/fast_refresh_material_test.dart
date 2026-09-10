import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default header and footer builders stay Classic', () {
    expect(FastRefresh.defaultHeaderBuilder(), isA<FastClassicHeader>());
    expect(FastRefresh.defaultFooterBuilder(), isA<FastClassicFooter>());
  });

  test('Material header clamps by default', () {
    const FastMaterialHeader header = FastMaterialHeader();
    expect(header.clamping, isTrue);
    expect(header.triggerOffset, 70);
    expect(header.processedDuration, Duration.zero);
    expect(header.infiniteOffset, isNull);
  });

  test('Material footer keeps Classic infinite-load gesture', () {
    const FastMaterialFooter footer = FastMaterialFooter();
    expect(footer.clamping, isFalse);
    expect(footer.infiniteOffset, 70);
    expect(footer.processedDuration, Duration.zero);
  });

  testWidgets('Material header builds RefreshProgressIndicator',
      (WidgetTester tester) async {
    final FastRefreshController controller = FastRefreshController(
      controlFinishRefresh: true,
    );
    final ScrollController scrollController = ScrollController();
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
            header: const FastMaterialHeader(
              safeArea: false,
              processedDuration: Duration.zero,
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
    await tester.pump(Duration.zero);
    await tester.drag(find.byType(Scrollable), const Offset(0, 100));
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsWidgets);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Material footer infinite-loads near the bottom',
      (WidgetTester tester) async {
    int loadCount = 0;
    final ScrollController scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FastRefresh(
            scrollController: scrollController,
            header: const FastMaterialHeader(safeArea: false),
            footer: const FastMaterialFooter(
              safeArea: false,
              processedDuration: Duration.zero,
            ),
            onLoad: () async {
              loadCount += 1;
              return FastRefreshResult.success;
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: 30,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(height: 80, child: Text('item $index'));
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(loadCount, greaterThanOrEqualTo(1));
  });

  testWidgets('Material color follows FastRefreshTheme',
      (WidgetTester tester) async {
    late Color resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const <ThemeExtension<dynamic>>[
            FastRefreshTheme(
              headerTexts: FastRefreshIndicatorTexts.headerEnglish,
              footerTexts: FastRefreshIndicatorTexts.footerEnglish,
              indicatorColor: Color(0xFF112233),
            ),
          ],
        ),
        home: Builder(
          builder: (BuildContext context) {
            resolved = FastRefreshTheme.resolve(context).indicatorColor!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, const Color(0xFF112233));
  });
}
