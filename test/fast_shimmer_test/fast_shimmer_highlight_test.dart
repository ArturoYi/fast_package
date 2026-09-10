import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    ),
  );
}

void main() {
  group('FastShimmerHighlight', () {
    testWidgets('creates a scope and shows the child', (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmerHighlight(
            child: Text('Highlight', style: TextStyle(color: Colors.white)),
          ),
        ),
      );

      expect(find.text('Highlight'), findsOneWidget);
      expect(find.byType(FastShimmerScope), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('text factory paints the string', (tester) async {
      await tester.pumpWidget(
        _app(
          FastShimmerHighlight.text(
            '滑动解锁',
            style: const TextStyle(fontSize: 18, color: Color(0x66FFFFFF)),
            highlightColor: Colors.white,
          ),
        ),
      );

      expect(find.text('滑动解锁'), findsOneWidget);
      expect(find.byType(FastShimmerScope), findsOneWidget);
    });

    testWidgets('creates a beam scope with 3s sweep and 1.8s pause',
        (tester) async {
      await tester.pumpWidget(
        _app(
          FastShimmerHighlight.text(
            '滑动解锁',
            style: const TextStyle(color: Color(0x66FFFFFF)),
            highlightColor: Colors.white,
          ),
        ),
      );

      final FastShimmerScope scope =
          tester.widget<FastShimmerScope>(find.byType(FastShimmerScope));
      expect(scope.sweep, FastShimmerSweep.beam);
      expect(scope.duration, FastShimmerHighlight.defaultDuration);
      expect(scope.pauseDuration, FastShimmerHighlight.defaultPauseDuration);
      expect(scope.bandWidth, FastShimmerHighlight.defaultBandWidth);
    });

    testWidgets('does not double-wrap an ancestor scope', (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmerScope(
            child: FastShimmerHighlight(
              child: Text('Nested', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );

      expect(find.byType(FastShimmerScope), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('Nested'), findsOneWidget);
    });
  });
}
