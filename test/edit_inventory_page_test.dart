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
        quantity: 1,
        volume: 1,
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
        quantity: 1,
        volume: 1,
        unit: '個',
        note: '',
      ),
    ));
    // 初期状態ではローディングが表示される
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('品種リストに無い初期値は自動で先頭に変更される',
      (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(
      MaterialApp(
        home: EditInventoryPage(
          id: '1',
          itemName: 'ティッシュ',
          category: cat,
          itemType: '存在しない品種',
          quantity: 1,
          volume: 1,
          unit: '個',
          note: '',
          categories: [cat],
        ),
      ),
    );
    await tester.pump();
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).first);
    expect(dropdown.initialValue ?? dropdown.value, 'その他');
  });

  testWidgets('容量入力欄が表示される', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(
      MaterialApp(
        home: EditInventoryPage(
          id: '1',
          itemName: 'ティッシュ',
          category: cat,
          itemType: '柔軟剤',
          quantity: 2,
          volume: 1.5,
          unit: '個',
          note: '',
          categories: [cat],
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(TextFormField).at(1), findsOneWidget);
  });
}
