import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/sale_list_page.dart';
import 'package:oouchi_stock/widgets/sale_item_card.dart';

void main() {
  testWidgets('SaleListPage 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SaleListPage()));
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SaleItemCard), findsWidgets);
  });
}
