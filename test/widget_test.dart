import 'package:flutter_test/flutter_test.dart';
import 'package:lexi/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const LexiApp());
    expect(find.text('Lexi'), findsOneWidget);
  });
}
