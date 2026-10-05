import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zteel_user/app_typography.dart';
import 'package:zteel_user/screens/customer_details_screen.dart';

void main() {
  Widget subject() => MaterialApp(
        theme: AppTypography.lightTheme(),
        home: const CustomerDetailsScreen(),
      );

  testWidgets('requires both names before customers can continue', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    final continueButton = find.byKey(const Key('name_continue_button'));
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('first_name_field')), 'Ada');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('last_name_field')), 'Lovelace');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);
  });
}
