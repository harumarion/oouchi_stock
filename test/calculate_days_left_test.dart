import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/usecases/calculate_days_left.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';

class FakeInventoryRepository implements InventoryRepository {
  List<HistoryEntry> history = [];

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) async* {
    yield history;
  }

  // 以下のメソッドはテストでは使用しない
  @override
  Stream<List<Inventory>> watchByCategory(String category) => throw UnimplementedError();
  @override
  Future<List<Inventory>> fetchAll() => throw UnimplementedError();
  @override
  Future<String> addInventory(Inventory inventory) => throw UnimplementedError();
  @override
  Future<void> updateQuantity(String id, double amount, String type) => throw UnimplementedError();
  @override
  Future<void> updateInventory(Inventory inventory) => throw UnimplementedError();
  @override
  Stream<Inventory?> watchInventory(String inventoryId) => throw UnimplementedError();
  @override
  Future<void> stocktake(String id, double before, double after, double diff) => throw UnimplementedError();
  @override
  Future<void> deleteInventory(String id) => throw UnimplementedError();
  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) => throw UnimplementedError();
}


void main() {
  test('履歴から残り日数を計算する', () async {
    final repo = FakeInventoryRepository();
    repo.history = [
      HistoryEntry('add', 2, DateTime(2023,1,1)),
      HistoryEntry('used', 1, DateTime(2023,1,2)),
    ];
    final usecase = CalculateDaysLeft(repo);
    final inv = Inventory(
        id: '1',
        itemName: 'test',
        category: 'cat',
        itemType: 'type',
        quantity: 1,
        unit: '個',
        monthlyConsumption: 0.5,
        createdAt: DateTime.now());
    final days = await usecase(inv);
    expect(days, 60);
  });
}
