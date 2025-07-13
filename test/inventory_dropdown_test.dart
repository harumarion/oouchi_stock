import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/inventory_dropdown.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';

void main() {
  testWidgets('商品名と品種の順で表示される', (WidgetTester tester) async {
    final inv = Inventory(
      id: '1',
      itemName: 'リンゴ',
      category: '果物',
      itemType: '青森',
      quantity: 1,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      note: '',
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InventoryDropdown(
          label: '商品',
          inventories: [inv],
          value: inv,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('リンゴ / 青森'), findsOneWidget);
  });
}
