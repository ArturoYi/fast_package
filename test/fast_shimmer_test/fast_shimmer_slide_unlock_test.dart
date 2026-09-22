import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 320, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('FastShimmerSlideUnlock', () {
    testWidgets('shows the hint label', (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmerSlideUnlock(label: '滑动解锁'),
        ),
      );

      expect(find.text('滑动解锁'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('crossing the threshold calls onUnlocked', (tester) async {
      var unlocked = false;

      await tester.pumpWidget(
        _app(
          FastShimmerSlideUnlock(
            label: '滑动解锁',
            successLabel: '已解锁',
            threshold: 0.6,
            resetOnUnlock: false,
            onUnlocked: () => unlocked = true,
          ),
        ),
      );

      await tester.drag(
        find.byIcon(Icons.chevron_right),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle();

      expect(unlocked, isTrue);
      expect(find.text('已解锁'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('a short drag does not unlock', (tester) async {
      var unlocked = false;

      await tester.pumpWidget(
        _app(
          FastShimmerSlideUnlock(
            resetOnUnlock: false,
            onUnlocked: () => unlocked = true,
          ),
        ),
      );

      await tester.drag(
        find.byType(FastShimmerSlideUnlock),
        const Offset(40, 0),
      );
      await tester.pump();

      expect(unlocked, isFalse);
      expect(find.text('滑动解锁'), findsOneWidget);
    });

    testWidgets('disabled control ignores a full drag', (tester) async {
      var unlocked = false;

      await tester.pumpWidget(
        _app(
          FastShimmerSlideUnlock(
            enabled: false,
            resetOnUnlock: false,
            onUnlocked: () => unlocked = true,
          ),
        ),
      );

      await tester.drag(
        find.byType(FastShimmerSlideUnlock),
        const Offset(260, 0),
      );
      await tester.pump();

      expect(unlocked, isFalse);
    });

    testWidgets('label highlight keeps the hint centered under a local beam',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmerSlideUnlock(
            highlight: FastShimmerSlideUnlockHighlight.label,
          ),
        ),
      );

      expect(find.text('滑动解锁'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(FastShimmerHighlight), findsOneWidget);
      final ShaderMask mask =
          tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(mask.blendMode, BlendMode.srcIn);
      final FastShimmerScope scope =
          tester.widget<FastShimmerScope>(find.byType(FastShimmerScope));
      expect(scope.sheenRotation, 0);
    });

    testWidgets('area and label both create a beam with the same timing',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FastShimmerSlideUnlock(
                highlight: FastShimmerSlideUnlockHighlight.area,
              ),
              FastShimmerSlideUnlock(
                highlight: FastShimmerSlideUnlockHighlight.label,
              ),
            ],
          ),
        ),
      );

      final Iterable<FastShimmerScope> scopes =
          tester.widgetList<FastShimmerScope>(find.byType(FastShimmerScope));
      expect(scopes, hasLength(2));
      for (final FastShimmerScope scope in scopes) {
        expect(scope.sweep, FastShimmerSweep.beam);
        expect(scope.duration, FastShimmerHighlight.defaultDuration);
        expect(scope.pauseDuration, FastShimmerHighlight.defaultPauseDuration);
      }
    });

    testWidgets('thumb follows the finger before release', (tester) async {
      await tester.pumpWidget(
        _app(const FastShimmerSlideUnlock()),
      );

      final Finder icon = find.byIcon(Icons.chevron_right);
      final double start = tester.getTopLeft(icon).dx;
      final TestGesture gesture =
          await tester.startGesture(tester.getCenter(icon));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();

      expect(tester.getTopLeft(icon).dx, greaterThan(start + 50));
      await gesture.up();
      await tester.pump();
    });

    testWidgets('a short swipe can be followed by a full swipe',
        (tester) async {
      var unlocked = false;

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: FastShimmerSlideUnlock(
                  threshold: 0.85,
                  resetOnUnlock: false,
                  onUnlocked: () => unlocked = true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.drag(
        find.byType(FastShimmerSlideUnlock),
        const Offset(30, 0),
      );
      // First frame stamps the spring's start time; the next pump advances it.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(unlocked, isFalse);

      await tester.drag(
        find.byType(FastShimmerSlideUnlock),
        const Offset(280, 0),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(unlocked, isTrue);
    });

    testWidgets('resetOnUnlock can be enabled without blocking unlock',
        (tester) async {
      var unlocked = false;

      await tester.pumpWidget(
        _app(
          FastShimmerSlideUnlock(
            threshold: 0.6,
            resetOnUnlock: true,
            onUnlocked: () => unlocked = true,
          ),
        ),
      );

      await tester.drag(
        find.byIcon(Icons.chevron_right),
        const Offset(280, 0),
      );
      await tester.pump();
      expect(unlocked, isTrue);
    });
  });
}
