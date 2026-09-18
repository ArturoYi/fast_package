import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example index lists gallery entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('toast example'), findsOneWidget);
    expect(find.text('refresh example'), findsOneWidget);
    expect(find.text('animated list example'), findsOneWidget);
  });
}
