import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_list_page.dart';

void main() {
  testWidgets('PriceListPage 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PriceListPage()));
    expect(find.byType(AppBar), findsOneWidget);
    // 検索バーが表示されるか確認
    expect(find.byType(TextField), findsWidgets);
  });
}
