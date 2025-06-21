import '../entities/inventory.dart';
import '../entities/price_info.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/price_repository.dart';
import '../services/auto_buy_list_service.dart';

/// アプリ起動時に在庫と価格情報を確認し、買い物リストへ自動追加するユースケース
class AutoAddBuyList {
  /// 在庫データ取得用リポジトリ
  final InventoryRepository _inventoryRepo;

  /// 価格情報取得用リポジトリ
  final PriceRepository _priceRepo;

  /// 自動追加サービス
  final AutoBuyListService _service;

  AutoAddBuyList(this._inventoryRepo, this._priceRepo, this._service);

  /// 全在庫と最新価格を照合し、自動追加判定を行う
  Future<void> call() async {
    List<Inventory> list = [];
    try {
      list = await _inventoryRepo.fetchAll();
    } catch (e) {
      // 取得に失敗しても処理を続行
      return;
    }
    for (final inv in list) {
      PriceInfo? price;
      try {
        final prices =
            await _priceRepo.watchByType(inv.category, inv.itemType).first;
        price = prices.isNotEmpty ? prices.first : null;
      } catch (_) {
        price = null;
      }
      await _service.process(inv, price);
    }
  }
}
