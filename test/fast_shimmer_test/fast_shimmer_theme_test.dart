import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastShimmerDirection', () {
    test('toGradient maps each direction to expected alignments', () {
      const colors = <Color>[Colors.red, Colors.white, Colors.red];
      const stops = <double>[0.0, 0.5, 1.0];

      final leftToRight = FastShimmerDirection.leftToRight.toGradient(
        colors: colors,
        stops: stops,
      );
      expect(leftToRight.begin, Alignment.centerLeft);
      expect(leftToRight.end, Alignment.centerRight);

      final rightToLeft = FastShimmerDirection.rightToLeft.toGradient(
        colors: colors,
        stops: stops,
      );
      expect(rightToLeft.begin, Alignment.centerRight);
      expect(rightToLeft.end, Alignment.centerLeft);

      final topToBottom = FastShimmerDirection.topToBottom.toGradient(
        colors: colors,
        stops: stops,
      );
      expect(topToBottom.begin, Alignment.topCenter);
      expect(topToBottom.end, Alignment.bottomCenter);

      final bottomToTop = FastShimmerDirection.bottomToTop.toGradient(
        colors: colors,
        stops: stops,
      );
      expect(bottomToTop.begin, Alignment.bottomCenter);
      expect(bottomToTop.end, Alignment.topCenter);

      final diagonal = FastShimmerDirection.diagonal.toGradient(
        colors: colors,
        stops: stops,
      );
      expect(diagonal.begin, Alignment.topLeft);
      expect(diagonal.end, Alignment.bottomRight);
    });
  });

  group('FastShimmerTheme.resolve', () {
    testWidgets('falls back to light defaults for light brightness',
        (tester) async {
      late FastShimmerTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              resolved = FastShimmerTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.baseColor, FastShimmerTheme.light.baseColor);
      expect(resolved.highlightColor, FastShimmerTheme.light.highlightColor);
      expect(resolved.direction, FastShimmerTheme.light.direction);
    });

    testWidgets('falls back to dark defaults for dark brightness',
        (tester) async {
      late FastShimmerTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              resolved = FastShimmerTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.baseColor, FastShimmerTheme.dark.baseColor);
      expect(resolved.highlightColor, FastShimmerTheme.dark.highlightColor);
    });

    testWidgets('prefers ThemeExtension when registered', (tester) async {
      const custom = FastShimmerTheme(
        baseColor: Color(0xFF111111),
        highlightColor: Color(0xFFEEEEEE),
        duration: Duration(milliseconds: 900),
        direction: FastShimmerDirection.diagonal,
      );
      late FastShimmerTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const <ThemeExtension<dynamic>>[custom],
          ),
          home: Builder(
            builder: (context) {
              resolved = FastShimmerTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.baseColor, custom.baseColor);
      expect(resolved.direction, FastShimmerDirection.diagonal);
    });

    testWidgets('widget-level overrides win over extension', (tester) async {
      late FastShimmerTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const <ThemeExtension<dynamic>>[
              FastShimmerTheme.light,
            ],
          ),
          home: Builder(
            builder: (context) {
              resolved = FastShimmerTheme.resolve(
                context,
                baseColor: Colors.orange,
                direction: FastShimmerDirection.topToBottom,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.baseColor, Colors.orange);
      expect(resolved.direction, FastShimmerDirection.topToBottom);
      expect(resolved.highlightColor, FastShimmerTheme.light.highlightColor);
    });
  });
}
