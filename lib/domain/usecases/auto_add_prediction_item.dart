import '../entities/inventory.dart';
import '../entities/price_info.dart';
import '../entities/buy_item.dart';
import '../usecases/add_prediction_item.dart';
import 'purchase_decision.dart';

/// 在庫と価格から買い物予報リストへ自動追加するユースケース
class AutoAddPredictionItem {
  /// 予報リスト追加ユースケース
  final AddPredictionItem _add;

  /// 購入判定ユースケース
  final PurchaseDecision _decide;

  AutoAddPredictionItem(this._add, this._decide);

  /// 在庫と価格情報を評価して必要なら予報リストへ追加
  Future<void> call(Inventory inv, PriceInfo? price) async {
    final type = _decide(inv, price);
    if (type == PurchaseDecisionType.cautious ||
        type == PurchaseDecisionType.bulkOpportunity) {
      final reason = type == PurchaseDecisionType.cautious
          ? BuyItemReason.autoCautious
          : BuyItemReason.autoBulk;
      await _add(BuyItem(inv.itemName, inv.category, inv.id, reason));
    }
  }
}
