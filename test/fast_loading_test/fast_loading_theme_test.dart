import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastLoadingTheme.resolve', () {
    testWidgets('falls back to light defaults for light brightness', (
      tester,
    ) async {
      late FastLoadingTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastLoadingTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, FastLoadingTheme.light);
      expect(resolved.boxShadow, FastLoadingTheme.light.boxShadow);
      expect(resolved.barrierColor, FastLoadingTheme.light.barrierColor);
    });

    testWidgets('falls back to dark defaults for dark brightness', (
      tester,
    ) async {
      late FastLoadingTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastLoadingTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, FastLoadingTheme.dark);
      expect(resolved.boxShadow, FastLoadingTheme.dark.boxShadow);
    });

    testWidgets('prefers registered extension including barrierColor', (
      tester,
    ) async {
      const FastLoadingTheme custom = FastLoadingTheme(
        backgroundColor: Color(0xFF123456),
        indicatorColor: Color(0xFFFFFFFF),
        textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
        borderRadius: 4,
        padding: EdgeInsets.all(8),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0xFF000000), blurRadius: 2),
        ],
        barrierColor: Color(0x22000000),
      );
      late FastLoadingTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const <ThemeExtension<dynamic>>[custom],
          ),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastLoadingTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, custom);
    });
  });

  group('FastLoadingTheme.copyWith and lerp', () {
    test('copyWith replaces barrierColor and boxShadow', () {
      const List<BoxShadow> next = <BoxShadow>[
        BoxShadow(color: Color(0xFF112233), blurRadius: 4),
      ];
      final FastLoadingTheme copied = FastLoadingTheme.light.copyWith(
        boxShadow: next,
        barrierColor: const Color(0x11000000),
      );
      expect(copied.boxShadow, next);
      expect(copied.barrierColor, const Color(0x11000000));
      expect(copied.backgroundColor, FastLoadingTheme.light.backgroundColor);
    });

    test('lerp interpolates boxShadow toward the other theme', () {
      final FastLoadingTheme mid = FastLoadingTheme.light.lerp(
        FastLoadingTheme.dark,
        0.5,
      );
      expect(
        mid.boxShadow.first.color,
        Color.lerp(
          FastLoadingTheme.light.boxShadow.first.color,
          FastLoadingTheme.dark.boxShadow.first.color,
          0.5,
        ),
      );
      expect(
        mid.barrierColor,
        Color.lerp(
          FastLoadingTheme.light.barrierColor,
          FastLoadingTheme.dark.barrierColor,
          0.5,
        ),
      );
    });
  });
}
