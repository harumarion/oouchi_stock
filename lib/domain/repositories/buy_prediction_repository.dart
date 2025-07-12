import '../entities/buy_item.dart';

/// 買い物予報リストを操作するリポジトリ
abstract class BuyPredictionRepository {
  /// 予報リストの変更を監視する
  Stream<List<BuyItem>> watchItems();

  /// アイテムを追加する
  Future<void> addItem(BuyItem item);

  /// アイテムを削除する
  Future<void> removeItem(BuyItem item);

  /// 在庫IDに紐づくアイテムをすべて削除する
  Future<void> removeItemsByInventoryId(String inventoryId);
}
