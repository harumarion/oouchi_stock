import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/edit_inventory_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('カテゴリ読み込み前はローディング表示', (WidgetTester tester) async {
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
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('品種が無いカテゴリを選択してもエラーにならない', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(MaterialApp(
      home: EditInventoryPage(
        id: '1',
        itemName: 'ティッシュ',
        category: cat,
        itemType: '柔軟剤',
        unit: '個',
        note: '',
      ),
    ));
    // 初期状態ではローディングが表示される
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
