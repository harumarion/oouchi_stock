import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/inventory_card.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';

void main() {
  testWidgets('InventoryCard 表示テスト', (WidgetTester tester) async {
    final inv = Inventory(
      id: '1',
      itemName: 'ティッシュ',
      category: '日用品',
      itemType: '消耗品',
      quantity: 1.0,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester
        .pumpWidget(MaterialApp(home: InventoryCard(inventory: inv)));
    expect(find.textContaining('ティッシュ'), findsOneWidget);
  });

  testWidgets('buyOnly オプションで購入ボタンのみ表示',
      (WidgetTester tester) async {
    final inv = Inventory(
      id: '2',
      itemName: 'トイレットペーパー',
      category: '日用品',
      itemType: '消耗品',
      quantity: 1.0,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester
        .pumpWidget(MaterialApp(home: InventoryCard(inventory: inv, buyOnly: true)));
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('長い名前の場合にスクロール表示される', (WidgetTester tester) async {
    final inv = Inventory(
      id: '3',
      itemName: 'とてもとても長い商品名が続くテストケース',
      category: '日用品',
      itemType: 'ものすごく長い品種名テスト',
      quantity: 1.0,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(home: InventoryCard(inventory: inv)));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
