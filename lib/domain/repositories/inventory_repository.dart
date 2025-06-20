import '../entities/inventory.dart';
import '../entities/history_entry.dart';

/// 在庫データを操作するリポジトリ
abstract class InventoryRepository {
  /// カテゴリごとの在庫を監視する
  Stream<List<Inventory>> watchByCategory(String category);

  /// 全在庫を取得する
  Future<List<Inventory>> fetchAll();

  /// 在庫を追加してIDを返す
  Future<String> addInventory(Inventory inventory);

  /// 数量を増減させる
  Future<void> updateQuantity(String id, double amount, String type);

  /// 在庫情報を更新する
  Future<void> updateInventory(Inventory inventory);

  /// 指定IDの在庫情報をストリームで取得する
  Stream<Inventory?> watchInventory(String inventoryId);

  /// 履歴を監視する
  Stream<List<HistoryEntry>> watchHistory(String inventoryId);

  /// 棚卸しを記録する
  Future<void> stocktake(
      String id, double before, double after, double diff);

  /// 在庫を削除する
  Future<void> deleteInventory(String id);

  /// 残量が一定以下の在庫を監視する
  Stream<List<Inventory>> watchNeedsBuy(double threshold);
}
