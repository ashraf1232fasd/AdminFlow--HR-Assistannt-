import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midproject/main.dart';

void main() {
  testWidgets('Payroll app loads and shows start screen',
          (WidgetTester tester) async {
        // Build the Payroll app
        await tester.pumpWidget(const PayrollApp() as Widget);

        // Verify that the Start Screen text is visible
        expect(find.text('Payroll Management'), findsOneWidget);
        expect(find.text('Go to Dashboard'), findsOneWidget);

        // Simulate tapping the "Go to Dashboard" button
        await tester.tap(find.text('Go to Dashboard'));
        await tester.pumpAndSettle();

        // Verify that Employee list screen appears
        expect(find.text('Employees'), findsOneWidget);
      });
}
