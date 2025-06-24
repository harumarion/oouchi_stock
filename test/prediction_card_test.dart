import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/widgets/prediction_card.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';

class _FakeInventoryRepository implements InventoryRepository {
  @override
  Stream<Inventory?> watchInventory(String inventoryId) => Stream.value(Inventory(
        id: 'inv1',
        itemName: 'テスト',
        category: '日用品',
        itemType: '一般',
        quantity: 1.0,
        unit: '個',
        monthlyConsumption: 0,
        createdAt: DateTime.now(),
      ));

  // 以下のメソッドはテストでは使用しない
  @override
  Future<List<Inventory>> fetchAll() async => [];
  @override
  Future<String> addInventory(Inventory inventory) async => '';
  @override
  Future<void> updateQuantity(String id, double amount, String type) async {}
  @override
  Future<void> updateInventory(Inventory inventory) async {}
  @override
  Future<void> stocktake(String id, double before, double after, double diff) async {}
  @override
  Future<void> deleteInventory(String id) async {}
  @override
  Stream<List<Inventory>> watchByCategory(String category) => const Stream.empty();
  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) => const Stream.empty();
  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) => const Stream.empty();
}


void main() {
  testWidgets('PredictionCard 表示テスト', (WidgetTester tester) async {
    final item = BuyItem('テスト', '日用品', 'inv1');
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: PredictionCard(
        item: item,
        categories: categories,
        watchInventory: _FakeInventoryRepository().watchInventory,
        addToBuyList: (_) async {},
        removePrediction: (_) async {},
        calcDaysLeft: (_) async => 7,
      ),
    ));
    await tester.pump();
    expect(find.text('テスト'), findsOneWidget);
    // カードウィジェットとして表示されることを確認
    expect(find.byType(Card), findsOneWidget);
  });
}
