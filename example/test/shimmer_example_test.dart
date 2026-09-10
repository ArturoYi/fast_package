import 'package:example/pages/shimmer_example/highlight/shimmer_highlight_example.dart';
import 'package:example/pages/shimmer_example/shimmer_example.dart';
import 'package:example/pages/shimmer_example/skeleton/shimmer_skeleton_example.dart';
import 'package:example/pages/shimmer_example/slide_hint/shimmer_slide_hint_example.dart';
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
    expect(find.text('骨架屏'), findsOneWidget);
    expect(find.text('扫光文字'), findsOneWidget);
    expect(find.text('滑动解锁'), findsOneWidget);
  });

  testWidgets('skeleton example toggles skeleton and content', (tester) async {
    await tester.pumpWidget(_wrap(const ShimmerSkeletonExample()));
    await tester.pump();

    expect(find.byType(FastShimmerBox), findsWidgets);
    expect(find.text('Alex Chen'), findsNothing);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(find.text('Alex Chen'), findsOneWidget);
  });

  testWidgets('highlight example shows real shimmer text', (tester) async {
    await tester.pumpWidget(_wrap(const ShimmerHighlightExample()));
    await tester.pump();

    expect(find.text('FAST PACKAGE'), findsOneWidget);
    expect(find.text('立即开通'), findsOneWidget);
    expect(find.text('滑动解锁'), findsNothing);
    expect(find.byType(FastShimmerHighlight), findsWidgets);
  });

  testWidgets('slide unlock example hosts the slider and reset switch',
      (tester) async {
    await tester.pumpWidget(_wrap(const ShimmerSlideHintExample()));
    await tester.pump();

    expect(find.byType(FastShimmerSlideUnlock), findsNWidgets(2));
    expect(find.text('整条滑块区域'), findsOneWidget);
    expect(find.text('仅文字高光'), findsOneWidget);
    expect(find.text('滑动解锁'), findsNWidgets(2));
    expect(find.text('解锁后复位'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('hub opens the skeleton page', (tester) async {
    await tester.pumpWidget(_wrap(const ShimmerExample()));
    await tester.pump();

    await tester.tap(find.text('骨架屏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Shimmer · Skeleton'), findsOneWidget);
  });
}
