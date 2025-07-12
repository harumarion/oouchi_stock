import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/usecases/add_inventory.dart';
import 'package:oouchi_stock/domain/usecases/update_quantity.dart';
import 'package:oouchi_stock/domain/usecases/delete_inventory.dart';
import 'package:oouchi_stock/domain/usecases/stocktake.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';

/// テストで利用するフェイクの在庫リポジトリ
class FakeInventoryRepository implements InventoryRepository {
  /// AddInventory で追加された在庫
  Inventory? addedInventory;

  /// UpdateQuantity で指定されたID
  String? updateId;

  /// UpdateQuantity で指定された増減量
  double? updateAmount;

  /// UpdateQuantity の種類
  String? updateType;

  /// DeleteInventory で削除されたID
  String? deletedId;

  /// Stocktake で渡された引数
  Map<String, double>? stocktakeArgs;

  @override
  Future<String> addInventory(Inventory inventory) async {
    addedInventory = inventory;
    return 'fakeId';
  }

  @override
  Future<void> updateQuantity(String id, double amount, String type) async {
    updateId = id;
    updateAmount = amount;
    updateType = type;
  }

  @override
  Future<void> deleteInventory(String id) async {
    deletedId = id;
  }

  @override
  Future<void> stocktake(
      String id, double before, double after, double diff) async {
    stocktakeArgs = {
      'before': before,
      'after': after,
      'diff': diff,
    };
  }

  // The following methods are not needed for these tests
  @override
  Stream<List<Inventory>> watchByCategory(String category) =>
      throw UnimplementedError();
  @override
  Future<List<Inventory>> fetchAll() => throw UnimplementedError();
  @override
  Future<void> updateInventory(Inventory inventory) =>
      throw UnimplementedError();
  @override
  Stream<Inventory?> watchInventory(String inventoryId) =>
      throw UnimplementedError();
  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) =>
      throw UnimplementedError();
  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) =>
      throw UnimplementedError();
}

void main() {
  test('AddInventory が repository に Inventory を渡す', () async {
    final repo = FakeInventoryRepository();
    final usecase = AddInventory(repo);
    final inventory = Inventory(
      id: 'id1',
      itemName: 'name',
      category: 'cat',
      itemType: 'type',
      quantity: 1,
      volume: 1,
      totalVolume: 1,
      unit: '個',
      monthlyConsumption: 0,
      createdAt: DateTime.now(),
    );

    await usecase(inventory);

    expect(repo.addedInventory, same(inventory));
  });

  test('UpdateQuantity が repository.updateQuantity を呼び出す', () async {
    final repo = FakeInventoryRepository();
    final usecase = UpdateQuantity(repo);

    await usecase('id2', 3.0, 'used');

    expect(repo.updateId, 'id2');
    expect(repo.updateAmount, 3.0);
    expect(repo.updateType, 'used');
  });

  test('DeleteInventory が repository.deleteInventory を呼び出す', () async {
    final repo = FakeInventoryRepository();
    final usecase = DeleteInventory(repo);

    await usecase('id3');

    expect(repo.deletedId, 'id3');
  });

  test('Stocktake が repository.stocktake を呼び出す', () async {
    final repo = FakeInventoryRepository();
    final usecase = Stocktake(repo);

    await usecase('id4', 1.0, 2.0, 1.0);

    expect(repo.stocktakeArgs, {
      'before': 1.0,
      'after': 2.0,
      'diff': 1.0,
    });
  });
}
