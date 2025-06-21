import '../entities/inventory.dart';
import '../entities/price_info.dart';

/// 購入判定の種類
/// emergency: 在庫ゼロ
/// cautious: しきい値以下で高値
/// bulkOpportunity: 在庫十分でセール
/// bestTime: 在庫少でセール
/// none: 条件に当てはまらない場合
enum PurchaseDecisionType { none, emergency, cautious, bulkOpportunity, bestTime }

/// 在庫量と価格情報から購入判定を行うサービス
/// 在庫数と価格を比較し、買い時かどうかを分類する
class PurchaseDecisionService {
  /// 在庫量のしきい値。ここより少ないと「在庫少」とみなす
  final double threshold;

  PurchaseDecisionService(this.threshold);

  /// 判定を実行する
  /// [inv] 在庫データ、[price] 最新の価格情報を渡す
  /// 戻り値で購入タイミングを示す種別を返す
  PurchaseDecisionType decide(Inventory inv, PriceInfo? price) {
    // 在庫がゼロの場合は価格に関係なく緊急購入
    if (inv.quantity <= 0) {
      return PurchaseDecisionType.emergency;
    }

    // セール価格かどうか。null の場合は false
    final isSale = price != null && price.salePrice < price.regularPrice;
    // 通常価格以上なら高めと判定
    final isHigh = price != null && price.salePrice >= price.regularPrice;

    if (inv.quantity <= threshold) {
      if (isSale) {
        // 在庫少かつセール価格
        return PurchaseDecisionType.bestTime;
      }
      if (isHigh) {
        // 在庫少かつ価格高め
        return PurchaseDecisionType.cautious;
      }
    } else {
      if (isSale) {
        // 在庫十分でセール中
        return PurchaseDecisionType.bulkOpportunity;
      }
    }
    // どの条件にも当てはまらない場合は購入不要
    return PurchaseDecisionType.none;
  }
}
