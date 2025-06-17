import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_history_page.dart';

void main() {
  testWidgets('PriceHistoryPage が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PriceHistoryPage(category: '日用品', itemType: '洗剤'),
    ));
    expect(find.byType(AppBar), findsOneWidget);
  });
}
