import 'package:fast_package/fast_package.dart';
import 'package:fast_package/src/ui_kit/fast_toast/fast_toast_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final FastToastController controller = FastToastController.instance;

  setUp(controller.resetForTest);
  tearDown(controller.resetForTest);

  Widget buildApp({required Widget home}) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return FastToastOverlay(child: child ?? const SizedBox.shrink());
      },
      home: home,
    );
  }

  group('FastToastController without overlay', () {
    test('enqueue before attach keeps pending and does not throw', () {
      expect(
        () => showToast('pending'),
        returnsNormally,
      );
      expect(FastToast.pendingCount, 1);
      expect(FastToast.isShowing, isFalse);
    });

    test('dismiss at idle is a no-op', () {
      FastToast.dismiss();
      expect(FastToast.isShowing, isFalse);
    });

    test('dismissAll clears pending when nothing is showing', () {
      showToast('a');
      showToast('b');
      FastToast.dismissAll();
      expect(FastToast.pendingCount, 0);
      expect(FastToast.isShowing, isFalse);
    });
  });

  group('FastToastController with overlay', () {
    testWidgets('shows one toast at a time in FIFO order', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showToast(
        'first',
        config: const FastToastConfig(duration: Duration(milliseconds: 300)),
      );
      showToast('second');
      await tester.pump();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
      expect(FastToast.isShowing, isTrue);
      expect(FastToast.pendingCount, 1);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('dismiss plays exit then shows the next toast', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showToast(
        'current',
        config: const FastToastConfig(duration: Duration(seconds: 10)),
      );
      showToast('next');
      await tester.pump();

      expect(find.text('current'), findsOneWidget);

      FastToast.dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(find.text('current'), findsNothing);
      expect(find.text('next'), findsOneWidget);
    });

    testWidgets('dismissAll during exit animation does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showToast(
        'exiting',
        config: const FastToastConfig(duration: Duration(seconds: 10)),
      );
      await tester.pump();

      FastToast.dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(() => FastToast.dismissAll(), returnsNormally);
      await tester.pump();

      expect(find.text('exiting'), findsNothing);
      expect(FastToast.isShowing, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dismissAll removes visible toast immediately', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showToast('gone');
      showToast('also-gone');
      await tester.pump();

      FastToast.dismissAll();
      await tester.pump();

      expect(find.text('gone'), findsNothing);
      expect(find.text('also-gone'), findsNothing);
      expect(FastToast.pendingCount, 0);
      expect(FastToast.isShowing, isFalse);
    });

    testWidgets('detach keeps pending queue for re-attach', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showToast(
        'visible',
        config: const FastToastConfig(duration: Duration(seconds: 10)),
      );
      showToast('after-detach');
      await tester.pump();

      expect(find.text('visible'), findsOneWidget);
      expect(FastToast.pendingCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(FastToast.pendingCount, 1);
      expect(FastToast.isShowing, isFalse);

      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      expect(find.text('after-detach'), findsOneWidget);
      expect(find.text('visible'), findsNothing);
    });

    testWidgets('show before overlay mount appears after attach', (
      tester,
    ) async {
      showToast('early');
      expect(FastToast.pendingCount, 1);
      expect(find.text('early'), findsNothing);

      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      expect(find.text('early'), findsOneWidget);
    });
  });
}
