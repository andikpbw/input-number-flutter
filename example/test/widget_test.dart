import 'package:flutter_input_number/flutter_input_number.dart';
import 'package:flutter_input_number_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InputNumberStudioApp renders all showcase cards cleanly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InputNumberStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('flutter_input_number'), findsOneWidget);
    expect(find.byType(FlutterInputNumber), findsWidgets);
  });
}
