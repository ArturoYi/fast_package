import 'package:fast_package/fast_package.dart';
import 'package:fast_package/src/ui_kit/fast_loading/fast_loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final FastLoadingController controller = FastLoadingController.instance;

  setUp(controller.resetForTest);
  tearDown(controller.resetForTest);

  Widget buildApp({required Widget home}) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return FastLoadingOverlay(child: child ?? const SizedBox.shrink());
      },
      home: home,
    );
  }

  group('FastLoadingController without overlay', () {
    test('show before attach keeps pending and does not throw', () {
      expect(() => showLoading(), returnsNormally);
      expect(FastLoading.isShowing, isFalse);
    });

    test('dismiss at idle is a no-op', () {
      FastLoading.dismiss();
      expect(FastLoading.isShowing, isFalse);
    });

    test('dismissNow clears pending when nothing is showing', () {
      showLoading(message: 'pending');
      FastLoading.dismissNow();
      expect(FastLoading.isShowing, isFalse);
    });
  });

  group('FastLoadingController with overlay', () {
    testWidgets('stays visible until dismissed', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'busy');
      await tester.pump();

      expect(find.text('busy'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('busy'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);

      FastLoading.dismissNow();
      await tester.pump();

      expect(find.text('busy'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('dismiss plays exit then removes the overlay', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'busy');
      await tester.pump();

      FastLoading.dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(find.text('busy'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('a later show replaces the current loading', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'first');
      await tester.pump();
      showLoading(message: 'second');
      await tester.pump();

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);
    });

    testWidgets('dismissNow removes visible loading immediately', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'gone');
      await tester.pump();

      FastLoading.dismissNow();
      await tester.pump();

      expect(find.text('gone'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
    });

    testWidgets('dismiss during exit animation does not throw', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'exiting');
      await tester.pump();

      FastLoading.dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(FastLoading.dismissNow, returnsNormally);
      await tester.pump();

      expect(find.text('exiting'), findsNothing);
      expect(FastLoading.isShowing, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('detach keeps current request for re-attach', (tester) async {
      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      showLoading(message: 'visible');
      await tester.pump();

      expect(find.text('visible'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(FastLoading.isShowing, isFalse);

      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      expect(find.text('visible'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);
    });

    testWidgets('show before overlay mount appears after attach', (
      tester,
    ) async {
      showLoading(message: 'early');
      expect(FastLoading.isShowing, isFalse);
      expect(find.text('early'), findsNothing);

      await tester.pumpWidget(
        buildApp(home: const Scaffold(body: Text('content'))),
      );
      await tester.pump();

      expect(find.text('early'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);
    });
  });

  group('FastLoadingController pop lock', () {
    testWidgets('maybePop is blocked until loading is dismissed', (tester) async {
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          builder: (BuildContext context, Widget? child) {
            return FastLoadingOverlay(
              navigatorKey: navigatorKey,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const _PopLockHome(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('open-page'));
      await tester.pumpAndSettle();
      expect(find.text('second-page'), findsOneWidget);

      showLoading(message: 'locking');
      await tester.pump();

      expect(navigatorKey.currentState!.canPop(), isTrue);
      expect(await navigatorKey.currentState!.maybePop(), isTrue);
      await tester.pump();
      expect(navigatorKey.currentState!.canPop(), isTrue);
      expect(find.text('second-page'), findsOneWidget);
      expect(find.text('locking'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);

      FastLoading.dismissNow();
      await tester.pump();

      expect(await navigatorKey.currentState!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('second-page'), findsNothing);
      expect(find.text('open-page'), findsOneWidget);
    });

    testWidgets('system back is consumed while loading is showing', (
      tester,
    ) async {
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          builder: (BuildContext context, Widget? child) {
            return FastLoadingOverlay(
              navigatorKey: navigatorKey,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const _PopLockHome(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('open-page'));
      await tester.pumpAndSettle();

      showLoading(message: 'locking');
      await tester.pump();

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pump();
      expect(find.text('second-page'), findsOneWidget);
      expect(FastLoading.isShowing, isTrue);

      FastLoading.dismissNow();
      await tester.pump();

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('second-page'), findsNothing);
    });

    testWidgets('lockPop false allows maybePop', (tester) async {
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          builder: (BuildContext context, Widget? child) {
            return FastLoadingOverlay(
              navigatorKey: navigatorKey,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const _PopLockHome(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('open-page'));
      await tester.pumpAndSettle();

      showLoading(
        message: 'unlocked',
        config: const FastLoadingConfig(lockPop: false),
      );
      await tester.pump();

      expect(navigatorKey.currentState!.canPop(), isTrue);
      expect(await navigatorKey.currentState!.maybePop(), isTrue);
      expect(navigatorKey.currentState!.canPop(), isFalse);
      expect(FastLoading.isShowing, isTrue);
    });
  });
}

class _PopLockHome extends StatelessWidget {
  const _PopLockHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return const Scaffold(body: Text('second-page'));
              },
            ),
          );
        },
        child: const Text('open-page'),
      ),
    );
  }
}
