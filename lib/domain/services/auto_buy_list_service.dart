import '../entities/inventory.dart';
import '../entities/price_info.dart';
import '../entities/buy_item.dart';
import '../usecases/add_buy_item.dart';
import 'purchase_decision_service.dart';

/// 在庫と価格から自動的に買い物リストへ追加するサービス
/// [PurchaseDecisionService] で判定し、緊急または買い時の場合に追加する
class AutoBuyListService {
  /// 買い物リスト追加ユースケース
  final AddBuyItem _add;

  /// 購入判定サービス
  final PurchaseDecisionService _decider;

  AutoBuyListService(this._add, this._decider);

  /// 指定在庫と価格情報を評価し、必要なら買い物リストへ追加する
  Future<void> process(Inventory inv, PriceInfo? price) async {
    final type = _decider.decide(inv, price);
    if (type == PurchaseDecisionType.emergency ||
        type == PurchaseDecisionType.bestTime) {
      // 自動追加対象の場合は買い物リストに登録
      await _add(BuyItem(inv.itemName, inv.category, inv.id));
    }
  }
}
