import '../entities/buy_item.dart';

/// 買い物リストを操作するリポジトリ
abstract class BuyListRepository {
  /// 買い物リストの変更を監視する
  Stream<List<BuyItem>> watchItems();

  /// アイテムを追加する
  Future<void> addItem(BuyItem item);

  /// アイテムを削除する
  Future<void> removeItem(BuyItem item);
}
