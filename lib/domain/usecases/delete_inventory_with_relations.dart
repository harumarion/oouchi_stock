import '../repositories/inventory_repository.dart';
import '../repositories/price_repository.dart';
import '../repositories/buy_list_repository.dart';
import '../repositories/buy_prediction_repository.dart';

/// 在庫削除時に関連データもまとめて削除するユースケース
class DeleteInventoryWithRelations {
  /// 在庫リポジトリ
  final InventoryRepository _inventory;

  /// 価格情報リポジトリ
  final PriceRepository _price;

  /// 買い物リストリポジトリ
  final BuyListRepository _buy;

  /// 買い物予報リポジトリ
  final BuyPredictionRepository _prediction;

  DeleteInventoryWithRelations(
    this._inventory,
    this._price,
    this._buy,
    this._prediction,
  );

  /// 在庫削除処理
  Future<void> call(String id) async {
    await _price.deleteByInventoryId(id);
    await _buy.removeItemsByInventoryId(id);
    await _prediction.removeItemsByInventoryId(id);
    await _inventory.deleteInventory(id);
  }
}
