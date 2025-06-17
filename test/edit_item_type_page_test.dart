import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/edit_item_type_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/domain/entities/item_type.dart';

void main() {
  testWidgets('EditItemTypePage 初期値表示', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    final item = ItemType(id: 1, category: '日用品', name: '洗剤', createdAt: DateTime.now());
    await tester.pumpWidget(MaterialApp(
      home: EditItemTypePage(itemType: item, categories: [cat]),
    ));
    expect(find.text('洗剤'), findsOneWidget);
  });
}
