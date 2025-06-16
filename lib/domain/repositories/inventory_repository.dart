import '../entities/inventory.dart';
import '../entities/history_entry.dart';

abstract class InventoryRepository {
  Stream<List<Inventory>> watchByCategory(String category);

  Future<List<Inventory>> fetchAll();

  Future<String> addInventory(Inventory inventory);

  Future<void> updateQuantity(String id, double amount, String type);

  Future<void> updateInventory(Inventory inventory);

  /// 指定IDの在庫情報をストリームで取得する
  Stream<Inventory?> watchInventory(String inventoryId);

  Stream<List<HistoryEntry>> watchHistory(String inventoryId);

  Future<void> stocktake(
      String id, double before, double after, double diff);

  /// 在庫を削除する
  Future<void> deleteInventory(String id);
}
