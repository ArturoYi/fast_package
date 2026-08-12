import 'package:example/pages/shimmer_example/shimmer_example.dart';
import 'package:example/routes/routes.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repeating shimmer animations never "settle", so tests disable them.
Widget _wrap(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('shimmer example toggles skeleton and content', (tester) async {
    await tester.pumpWidget(_wrap(const ShimmerExample()));
    await tester.pump();

    expect(find.byType(FastShimmerBox), findsWidgets);
    expect(find.text('Alex Chen'), findsNothing);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(find.text('Alex Chen'), findsOneWidget);
  });

  testWidgets('index lists shimmer route', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          routes: ExampleRoute.routes,
          initialRoute: ExampleRoute.initRoutes,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('shimmer example'), findsOneWidget);
    await tester.tap(find.text('shimmer example'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Shimmer Example'), findsOneWidget);
  });
}
