import '../entities/inventory.dart';
import '../entities/price_info.dart';
import '../entities/buy_item.dart';
import '../usecases/add_prediction_item.dart';
import 'purchase_decision_service.dart';

/// 在庫と価格から自動的に買い物予報リストへ追加するサービス
/// [PurchaseDecisionService] により慎重またはまとめ買いチャンスと判定された場合に追加する
class AutoPredictionListService {
  /// 予報リスト追加ユースケース
  final AddPredictionItem _add;

  /// 購入判定サービス
  final PurchaseDecisionService _decider;

  AutoPredictionListService(this._add, this._decider);

  /// 指定在庫と価格情報を評価し、必要なら予報リストへ追加する
  Future<void> process(Inventory inv, PriceInfo? price) async {
    final type = _decider.decide(inv, price);
    if (type == PurchaseDecisionType.cautious ||
        type == PurchaseDecisionType.bulkOpportunity) {
      await _add(BuyItem(inv.itemName, inv.category, inv.id));
    }
  }
}
