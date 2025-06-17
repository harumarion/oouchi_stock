import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_detail_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('InventoryDetailPage ローディング表示', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
