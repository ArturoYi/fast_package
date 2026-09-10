import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const FastRefreshTheme _zhTheme = FastRefreshTheme(
  headerTexts: FastRefreshIndicatorTexts(
    dragText: '下拉刷新',
    armedText: '释放刷新',
    readyText: '正在刷新...',
    processingText: '正在刷新...',
    processedText: '刷新成功',
    noMoreText: '没有更多了',
    failedText: '刷新失败',
    messageText: '上次更新 %T',
  ),
  footerTexts: FastRefreshIndicatorTexts.footerEnglish,
);

Widget _classicApp({
  ThemeData? theme,
  FastClassicHeader? header,
}) {
  return MaterialApp(
    theme: theme ?? ThemeData(brightness: Brightness.light),
    home: Scaffold(
      body: FastRefresh(
        header: header ?? const FastClassicHeader(showMessage: false),
        onRefresh: () async {},
        child: ListView(
          children: const <Widget>[
            SizedBox(height: 80, child: Text('item')),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('unstyled Classic keeps English defaults',
      (WidgetTester tester) async {
    await tester.pumpWidget(_classicApp());
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, 80));
    await tester.pump();
    expect(find.text('Pull to refresh'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('registered theme supplies Classic text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _classicApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const <ThemeExtension<dynamic>>[_zhTheme],
        ),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, 80));
    await tester.pump();
    expect(find.text('下拉刷新'), findsOneWidget);
    expect(find.text('Pull to refresh'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('widget text overrides theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      _classicApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: const <ThemeExtension<dynamic>>[_zhTheme],
        ),
        header: const FastClassicHeader(
          showMessage: false,
          dragText: '自定义',
        ),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(Scrollable), const Offset(0, 80));
    await tester.pump();
    expect(find.text('自定义'), findsOneWidget);
    expect(find.text('下拉刷新'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
  });
}
