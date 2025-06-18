import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/buy_list_condition_settings_page.dart';

void main() {
  testWidgets('BuyListConditionSettingsPage 表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuyListConditionSettingsPage()));
    expect(find.text('買うべきリスト条件設定'), findsOneWidget);
  });
}
