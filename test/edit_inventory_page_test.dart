import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/edit_inventory_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('EditInventoryPage が表示される', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(MaterialApp(
      home: EditInventoryPage(
        id: '1',
        itemName: 'ティッシュ',
        category: cat,
        itemType: '消耗品',
        unit: '個',
        note: '',
      ),
    ));
    expect(find.text('ティッシュ'), findsOneWidget);
  });
}
