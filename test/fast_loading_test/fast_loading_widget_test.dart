import 'package:fast_package/fast_package.dart';
import 'package:fast_package/src/ui_kit/fast_loading/fast_loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final FastLoadingController controller = FastLoadingController.instance;

  setUp(controller.resetForTest);
  tearDown(controller.resetForTest);

  Widget buildApp({
    List<ThemeExtension<dynamic>>? extensions,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        extensions: extensions ?? const <ThemeExtension<dynamic>>[],
      ),
      builder: (BuildContext context, Widget? child) {
        return FastLoadingOverlay(child: child ?? const SizedBox.shrink());
      },
      home: const Scaffold(body: Text('content')),
    );
  }

  testWidgets('showLoading displays spinner and optional message', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showLoading(message: '请稍候');
    await tester.pump();

    expect(find.text('请稍候'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
    expect(
      _panelDecoration(tester, '请稍候').boxShadow,
      FastLoadingTheme.light.boxShadow,
    );
    expect(
      _panelDecoration(tester, '请稍候').color,
      FastLoadingTheme.light.backgroundColor,
    );
  });

  testWidgets('showLoading without message shows spinner only', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showLoading();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
    expect(
      tester
          .widgetList<Text>(find.byType(Text))
          .where((Text text) => text.data != 'content'),
      isEmpty,
    );
  });

  testWidgets('showLoading builder shows caller widget without default panel', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showLoading(
      builder: (BuildContext context) {
        return const ColoredBox(
          key: Key('custom-loading'),
          color: Color(0xFF00C853),
          child: Text('custom-body'),
        );
      },
    );
    await tester.pump();

    expect(find.text('custom-body'), findsOneWidget);
    expect(find.byKey(const Key('custom-loading')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    final Iterable<DecoratedBox> themedPanels = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (DecoratedBox box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color ==
                  FastLoadingTheme.light.backgroundColor,
        );
    expect(themedPanels, isEmpty);
  });

  testWidgets('theme extension styles showLoading but not custom loading', (
    tester,
  ) async {
    const Color panelColor = Color(0xFF123456);
    const List<BoxShadow> panelShadow = <BoxShadow>[
      BoxShadow(color: Color(0xFF00C853), blurRadius: 8, offset: Offset(0, 2)),
    ];
    const FastLoadingTheme loadingTheme = FastLoadingTheme(
      backgroundColor: panelColor,
      indicatorColor: Color(0xFFFFFFFF),
      textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      borderRadius: 8,
      padding: EdgeInsets.all(12),
      boxShadow: panelShadow,
      barrierColor: Color(0x44000000),
    );

    await tester.pumpWidget(
      buildApp(extensions: const <ThemeExtension<dynamic>>[loadingTheme]),
    );
    await tester.pump();

    showLoading(message: 'themed');
    await tester.pump();

    expect(find.text('themed'), findsOneWidget);
    expect(_panelDecoration(tester, 'themed').color, panelColor);
    expect(_panelDecoration(tester, 'themed').boxShadow, panelShadow);

    FastLoading.dismissNow();
    await tester.pump();

    showLoading(
      builder: (BuildContext context) => const Text('plain-custom'),
    );
    await tester.pump();

    expect(find.text('plain-custom'), findsOneWidget);
    expect(_panelDecorationOrNull(tester, 'plain-custom'), isNull);
    expect(
      tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (DecoratedBox box) =>
                box.decoration is BoxDecoration &&
                (box.decoration as BoxDecoration).color == panelColor,
          ),
      isEmpty,
    );
  });

  testWidgets('showLoading uses dark boxShadow when brightness is dark', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(brightness: Brightness.dark));
    await tester.pump();

    showLoading(message: 'dark-panel');
    await tester.pump();

    expect(
      _panelDecoration(tester, 'dark-panel').boxShadow,
      FastLoadingTheme.dark.boxShadow,
    );
  });

  testWidgets('barrier blocks taps to the page beneath', (tester) async {
    var pageTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return FastLoadingOverlay(child: child ?? const SizedBox.shrink());
        },
        home: Scaffold(
          body: GestureDetector(
            onTap: () => pageTapped = true,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(child: Text('content')),
          ),
        ),
      ),
    );
    await tester.pump();

    showLoading(message: 'blocking');
    await tester.pump();

    await tester.tapAt(const Offset(12, 12));
    await tester.pump();

    expect(pageTapped, isFalse);
    expect(find.text('blocking'), findsOneWidget);
  });

  testWidgets('barrierDismissible closes loading on barrier tap', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showLoading(
      message: 'tap-barrier',
      config: const FastLoadingConfig(barrierDismissible: true),
    );
    await tester.pump();

    await tester.tapAt(const Offset(12, 12));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('tap-barrier'), findsNothing);
    expect(FastLoading.isShowing, isFalse);
  });

  testWidgets('default panel width is capped', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showLoading(message: 'long message ' * 16);
    await tester.pump();

    final Size panelSize = tester.getSize(
      find
          .ancestor(
            of: find.textContaining('long message'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(panelSize.width, lessThanOrEqualTo(240));
  });
}

BoxDecoration? _panelDecorationOrNull(WidgetTester tester, String message) {
  final Finder finder = find.ancestor(
    of: find.text(message),
    matching: find.byType(DecoratedBox),
  );
  if (finder.evaluate().isEmpty) {
    return null;
  }
  final DecoratedBox panel = tester.widget<DecoratedBox>(finder.first);
  return panel.decoration as BoxDecoration;
}

BoxDecoration _panelDecoration(WidgetTester tester, String message) {
  final DecoratedBox panel = tester.widget<DecoratedBox>(
    find
        .ancestor(
          of: find.text(message),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return panel.decoration as BoxDecoration;
}
