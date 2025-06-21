import 'package:flutter/foundation.dart';
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
    // 取得した在庫一覧
    List<Inventory> list = [];
    try {
      list = await _inventoryRepo.fetchAll();
    } catch (e, st) {
      // 在庫取得に失敗した場合はログを出力し、空リストとして続行
      debugPrint('在庫取得失敗: $e\n$st');
    }

    // 各在庫ごとに最新価格を取得して自動追加判定
    for (final inv in list) {
      PriceInfo? price;
      try {
        final prices =
            await _priceRepo.watchByType(inv.category, inv.itemType).first;
        price = prices.isNotEmpty ? prices.first : null;
      } catch (e, st) {
        // 価格取得に失敗した場合は null として処理
        debugPrint('価格取得失敗: $e\n$st');
        price = null;
      }
      await _service.process(inv, price);
    }
  }
}
