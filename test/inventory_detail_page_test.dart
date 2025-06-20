import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_detail_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';

class _FakeRepository implements InventoryRepository {
  @override
  Stream<Inventory?> watchInventory(String inventoryId) => Stream.value(null);

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) => Stream.value([]);

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
}

void main() {
  testWidgets('InventoryDetailPage ローディング表示', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('データが取得できない場合にエラー表示', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        repository: _FakeRepository(),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Load error'), findsOneWidget);
  });
}
