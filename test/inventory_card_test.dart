import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/main.dart';
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
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(home: InventoryCard(inventory: inv)));
    expect(find.textContaining('ティッシュ'), findsOneWidget);
  });
}
