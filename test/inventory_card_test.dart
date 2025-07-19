import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/inventory_card.dart';
import 'package:oouchi_stock/widgets/card_menu_button.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';

void main() {
  testWidgets('InventoryCard 表示テスト', (WidgetTester tester) async {
    final inv = Inventory(
      id: '1',
      itemName: 'ティッシュ',
      category: '日用品',
      itemType: '消耗品',
      quantity: 1.0,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
        home: InventoryCard(
      inventory: inv,
      updateQuantity: (_, __, ___) async {},
      stocktake: (_, __, ___, ____) async {},
    )));
    expect(find.textContaining('ティッシュ'), findsOneWidget);
  });

  testWidgets('buyOnly オプションでもメニューボタンが表示される',
      (WidgetTester tester) async {
    final inv = Inventory(
      id: '2',
      itemName: 'トイレットペーパー',
      category: '日用品',
      itemType: '消耗品',
      quantity: 1.0,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
        home: InventoryCard(
      inventory: inv,
      updateQuantity: (_, __, ___) async {},
      stocktake: (_, __, ___, ____) async {},
      buyOnly: true,
    )));
    expect(find.byType(CardMenuButton), findsOneWidget);
  });

  testWidgets('メニューボタンタップでボトムシート表示',
      (WidgetTester tester) async {
    final inv = Inventory(
      id: '4',
      itemName: 'ボトムシートテスト',
      category: '日用品',
      itemType: '消耗品',
      quantity: 1.0,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: InventoryCard(
        inventory: inv,
        updateQuantity: (_, __, ___) async {},
        stocktake: (_, __, ___, ____) async {},
      ),
    ));
    await tester.tap(find.byType(CardMenuButton));
    await tester.pumpAndSettle();
    expect(find.text('在庫調整'), findsOneWidget);
    expect(find.text('使用量入力'), findsOneWidget);
    expect(find.text('購入量入力'), findsOneWidget);
  });

  testWidgets('長い名前の場合にスクロール表示される', (WidgetTester tester) async {
    final inv = Inventory(
      id: '3',
      itemName: 'とてもとても長い商品名が続くテストケース',
      category: '日用品',
      itemType: 'ものすごく長い品種名テスト',
      quantity: 1.0,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
        home: InventoryCard(
      inventory: inv,
      updateQuantity: (_, __, ___) async {},
      stocktake: (_, __, ___, ____) async {},
    )));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
