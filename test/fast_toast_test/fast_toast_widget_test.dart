import 'package:fast_package/fast_package.dart';
import 'package:fast_package/src/ui_kit/fast_toast/fast_toast_controller.dart';
import 'package:fast_package/src/ui_kit/fast_toast/widgets/fast_toast_keyboard_shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final FastToastController controller = FastToastController.instance;

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
        return FastToastOverlay(child: child ?? const SizedBox.shrink());
      },
      home: const Scaffold(body: Text('content')),
    );
  }

  testWidgets('showToast displays message and hides after duration', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showToast(
      'saved',
      config: const FastToastConfig(duration: Duration(milliseconds: 300)),
    );
    await tester.pump();

    expect(find.text('saved'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
    expect(
      _panelDecoration(tester, 'saved').boxShadow,
      FastToastTheme.light.boxShadow,
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('saved'), findsNothing);
  });

  testWidgets('showCustomToast shows caller widget without default panel', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showCustomToast(
      const ColoredBox(
        key: Key('custom-toast'),
        color: Color(0xFF00C853),
        child: Text('custom-body'),
      ),
    );
    await tester.pump();

    expect(find.text('custom-body'), findsOneWidget);
    expect(find.byKey(const Key('custom-toast')), findsOneWidget);

    final Iterable<DecoratedBox> themedPanels = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (DecoratedBox box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color ==
                  FastToastTheme.light.backgroundColor,
        );
    expect(themedPanels, isEmpty);
  });

  testWidgets('dismissible toast closes on tap', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showToast(
      'tap me',
      config: const FastToastConfig(dismissible: true),
    );
    await tester.pump();

    await tester.tap(find.text('tap me'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('tap me'), findsNothing);
  });

  testWidgets('theme extension styles showToast but not custom toast', (
    tester,
  ) async {
    const Color panelColor = Color(0xFF123456);
    const List<BoxShadow> panelShadow = <BoxShadow>[
      BoxShadow(color: Color(0xFF00C853), blurRadius: 8, offset: Offset(0, 2)),
    ];
    const FastToastTheme toastTheme = FastToastTheme(
      backgroundColor: panelColor,
      textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      borderRadius: 8,
      padding: EdgeInsets.all(12),
      boxShadow: panelShadow,
    );

    await tester.pumpWidget(
      buildApp(extensions: const <ThemeExtension<dynamic>>[toastTheme]),
    );
    await tester.pump();

    showToast('themed');
    await tester.pump();

    expect(find.text('themed'), findsOneWidget);
    expect(_panelDecoration(tester, 'themed').color, panelColor);
    expect(_panelDecoration(tester, 'themed').boxShadow, panelShadow);

    FastToast.dismissAll();
    await tester.pump();

    showCustomToast(const Text('plain-custom'));
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

  testWidgets('showToast uses dark boxShadow when brightness is dark', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(brightness: Brightness.dark));
    await tester.pump();

    showToast('dark-panel');
    await tester.pump();

    expect(
      _panelDecoration(tester, 'dark-panel').boxShadow,
      FastToastTheme.dark.boxShadow,
    );
  });

  testWidgets('taps outside the toast reach the page beneath', (tester) async {
    var pageTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return FastToastOverlay(child: child ?? const SizedBox.shrink());
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

    showToast(
      'center-toast',
      config: const FastToastConfig(duration: Duration(seconds: 10)),
    );
    await tester.pump();

    await tester.tapAt(const Offset(12, 12));
    await tester.pump();

    expect(pageTapped, isTrue);
    expect(find.text('center-toast'), findsOneWidget);
  });

  testWidgets('text panel width is capped', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    showToast(
      'long message ' * 24,
      config: const FastToastConfig(duration: Duration(seconds: 10)),
    );
    await tester.pump();

    final Size panelSize = tester.getSize(
      find
          .ancestor(
            of: find.textContaining('long message'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(panelSize.width, lessThanOrEqualTo(400));
  });

  testWidgets('bottom toast follows keyboard on the compositing layer', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewInsets = FakeViewPadding.zero;

    await tester.pumpWidget(buildApp());
    await tester.pump();

    showToast(
      'keyboard',
      config: const FastToastConfig(
        position: FastToastPosition.bottom,
        duration: Duration(seconds: 10),
      ),
    );
    await tester.pump();

    final RenderFastToastKeyboardShift shift = tester
        .renderObject<RenderFastToastKeyboardShift>(
          find.byType(FastToastKeyboardShift),
        );
    expect(shift.translation.dy, -(34 + FastToastPosition.bottom.edgeInset));

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    expect(shift.translation.dy, -(300 + FastToastPosition.bottom.edgeInset));
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
