import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastShimmerScope', () {
    testWidgets('of returns value in 0..1 inside a scope', (tester) async {
      double? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: FastShimmerScope(
            child: Builder(
              builder: (context) {
                captured = FastShimmerScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured, greaterThanOrEqualTo(0.0));
      expect(captured, lessThanOrEqualTo(1.0));
    });

    testWidgets('of falls back to 0.5 without a scope ancestor', (tester) async {
      double? value;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = FastShimmerScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, 0.5);
    });

    testWidgets('maybeOf returns null without a scope ancestor', (tester) async {
      double? value = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = FastShimmerScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, isNull);
    });

    testWidgets('hasScope is true only with an ancestor scope', (tester) async {
      late bool outside;
      late bool inside;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (outerContext) {
              outside = FastShimmerScope.hasScope(outerContext);
              return FastShimmerScope(
                child: Builder(
                  builder: (innerContext) {
                    inside = FastShimmerScope.hasScope(innerContext);
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(outside, isFalse);
      expect(inside, isTrue);
    });

    testWidgets('FastShimmer does not double-wrap an existing scope',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FastShimmerScope(
            child: FastShimmer(
              isLoading: true,
              skeleton: FastShimmerBox(width: 100, height: 20),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(FastShimmerScope), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('FastShimmer auto-wraps a scope when none exists',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FastShimmer(
            isLoading: true,
            skeleton: FastShimmerBox(width: 100, height: 20),
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(FastShimmerScope), findsOneWidget);
    });

    testWidgets('freezes at 0.5 when disableAnimations is true', (tester) async {
      double? captured;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: FastShimmerScope(
              child: Builder(
                builder: (context) {
                  captured = FastShimmerScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(captured, 0.5);
    });
  });
}
