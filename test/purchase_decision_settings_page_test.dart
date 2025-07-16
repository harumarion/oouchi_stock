import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oouchi_stock/purchase_decision_settings_page.dart';

void main() {
  testWidgets('PurchaseDecisionSettingsPage 表示', (tester) async {
    SharedPreferences.setMockInitialValues({
      'pd_cautious_days': 3,
      'pd_best_days': 3,
      'pd_discount_percent': 10.0,
    });
    await tester.pumpWidget(const MaterialApp(home: PurchaseDecisionSettingsPage()));
    await tester.pump();
    expect(find.text('購入判定設定'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('入力した値が保持される', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: PurchaseDecisionSettingsPage()));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.enterText(find.byType(TextField).at(1), '7');
    await tester.enterText(find.byType(TextField).at(2), '15');
    await tester.pump();
    expect(find.widgetWithText(TextField, '5'), findsOneWidget);
    expect(find.widgetWithText(TextField, '7'), findsOneWidget);
    expect(find.widgetWithText(TextField, '15'), findsOneWidget);
  });
}
