import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('InventoryPage 検索バー表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: InventoryPage(categories: categories)));
    // タブが描画されるまで待機
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
  });
}
