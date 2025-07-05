import '../entities/inventory.dart';
import '../entities/price_info.dart';
import '../entities/buy_item.dart';
import '../usecases/add_buy_item.dart';
import 'purchase_decision.dart';

/// 在庫と価格から買い物リストへ自動追加するユースケース
class AutoAddBuyItem {
  /// 買い物リスト追加ユースケース
  final AddBuyItem _add;

  /// 購入判定ユースケース
  final PurchaseDecision _decide;

  AutoAddBuyItem(this._add, this._decide);

  /// 在庫と価格情報を評価して必要ならリストへ追加
  Future<void> call(Inventory inv, PriceInfo? price) async {
    final type = _decide(inv, price);
    if (type == PurchaseDecisionType.emergency ||
        type == PurchaseDecisionType.bestTime) {
      await _add(BuyItem(inv.itemName, inv.category, inv.id));
    }
  }
}
