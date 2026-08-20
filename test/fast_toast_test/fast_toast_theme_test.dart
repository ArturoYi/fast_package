import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastToastTheme.resolve', () {
    testWidgets('falls back to light defaults for light brightness', (
      tester,
    ) async {
      late FastToastTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastToastTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, FastToastTheme.light);
      expect(resolved.boxShadow, FastToastTheme.light.boxShadow);
    });

    testWidgets('falls back to dark defaults for dark brightness', (
      tester,
    ) async {
      late FastToastTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastToastTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, FastToastTheme.dark);
      expect(resolved.boxShadow, FastToastTheme.dark.boxShadow);
    });

    testWidgets('prefers registered extension including boxShadow', (
      tester,
    ) async {
      const FastToastTheme custom = FastToastTheme(
        backgroundColor: Color(0xFF123456),
        textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
        borderRadius: 4,
        padding: EdgeInsets.all(8),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0xFF000000), blurRadius: 2),
        ],
      );
      late FastToastTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const <ThemeExtension<dynamic>>[custom],
          ),
          home: Builder(
            builder: (BuildContext context) {
              resolved = FastToastTheme.resolve(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, custom);
    });
  });

  group('FastToastTheme.copyWith and lerp', () {
    test('copyWith replaces boxShadow', () {
      const List<BoxShadow> next = <BoxShadow>[
        BoxShadow(color: Color(0xFF112233), blurRadius: 4),
      ];
      final FastToastTheme copied = FastToastTheme.light.copyWith(
        boxShadow: next,
      );
      expect(copied.boxShadow, next);
      expect(copied.backgroundColor, FastToastTheme.light.backgroundColor);
    });

    test('lerp interpolates boxShadow toward the other theme', () {
      final FastToastTheme mid = FastToastTheme.light.lerp(
        FastToastTheme.dark,
        0.5,
      );
      expect(
        mid.boxShadow.first.color,
        Color.lerp(
          FastToastTheme.light.boxShadow.first.color,
          FastToastTheme.dark.boxShadow.first.color,
          0.5,
        ),
      );
    });
  });
}
