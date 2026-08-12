import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home,
  );
}

void main() {
  group('FastShimmer isLoading switch', () {
    testWidgets('shows child when isLoading is false', (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmer(
            isLoading: false,
            skeleton: FastShimmerBox(width: 100, height: 20),
            child: Text('Real content'),
          ),
        ),
      );

      expect(find.text('Real content'), findsOneWidget);
      expect(find.byType(FastShimmerBox), findsNothing);
      expect(find.byType(FastShimmerScope), findsNothing);
    });

    testWidgets('shows skeleton and hides child when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmer(
            isLoading: true,
            skeleton: FastShimmerBox(width: 100, height: 20),
            child: Text('Hidden'),
          ),
        ),
      );

      expect(find.text('Hidden'), findsNothing);
      expect(find.byType(FastShimmerBox), findsOneWidget);
      expect(find.byType(FastShimmerScope), findsOneWidget);
    });

    testWidgets('toggling isLoading reveals child after loading', (tester) async {
      var loading = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _app(
              Column(
                children: [
                  FastShimmer(
                    isLoading: loading,
                    skeleton: const FastShimmerBox(width: 80, height: 16),
                    child: const Text('Profile'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => loading = false),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Profile'), findsNothing);
      expect(find.byType(FastShimmerBox), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(FastShimmerBox), findsNothing);
    });

    testWidgets('exposes Loading semantics while showing skeleton',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const FastShimmer(
            isLoading: true,
            skeleton: FastShimmerBox(width: 100, height: 20),
            child: Text('Content'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });
  });
}
