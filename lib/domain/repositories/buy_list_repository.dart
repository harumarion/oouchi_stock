import '../entities/buy_item.dart';

/// 買い物リストを操作するリポジトリ
abstract class BuyListRepository {
  /// 買い物リストの変更を監視する
  Stream<List<BuyItem>> watchItems();

  /// アイテムを追加する
  Future<void> addItem(BuyItem item);

  /// アイテムを削除する
  Future<void> removeItem(BuyItem item);

  /// 手動削除した在庫IDを保存する
  Future<void> addIgnoredId(String id);

  /// 手動削除状態を解除する
  Future<void> removeIgnoredId(String id);

  /// 保存された削除済み在庫ID一覧を取得する
  Future<List<String>> loadIgnoredIds();

  /// 在庫IDに紐づくアイテムをすべて削除する
  Future<void> removeItemsByInventoryId(String inventoryId);
}
