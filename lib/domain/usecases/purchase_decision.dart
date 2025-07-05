import '../entities/inventory.dart';
import '../entities/price_info.dart';

/// 購入判定の種類
/// emergency: 在庫ゼロ
/// cautious: 残り日数が設定以下
/// bulkOpportunity: 在庫十分でセール
/// bestTime: 残り日数が設定以下かつ十分な値引き
/// none: 条件に当てはまらない場合
enum PurchaseDecisionType {
  none,
  emergency,
  cautious,
  bulkOpportunity,
  bestTime,
}

/// 在庫量と価格情報から購入判定を行うユースケース
class PurchaseDecision {
  /// 在庫量のしきい値
  final double threshold;

  /// 慎重判定となる残り日数
  final int cautiousDays;

  /// 買い時判定となる残り日数
  final int bestTimeDays;

  /// セール価格が通常価格より何パーセント安いと買い時とするか
  final double discountPercent;

  PurchaseDecision(
    this.threshold, {
    required this.cautiousDays,
    required this.bestTimeDays,
    required this.discountPercent,
  });

  int _daysLeft(Inventory inv) {
    if (inv.monthlyConsumption <= 0) return 9999;
    return (inv.quantity / inv.monthlyConsumption * 30).ceil();
  }

  /// 判定を実行する
  PurchaseDecisionType call(Inventory inv, PriceInfo? price) {
    if (inv.quantity <= 0) {
      return PurchaseDecisionType.emergency;
    }
    final isSale = price != null && price.salePrice < price.regularPrice;
    final discount = price != null
        ? (price.regularPrice - price.salePrice) / price.regularPrice * 100
        : 0.0;
    final days = _daysLeft(inv);

    if (days <= bestTimeDays &&
        isSale &&
        discount >= discountPercent) {
      return PurchaseDecisionType.bestTime;
    }
    if (days <= cautiousDays) {
      return PurchaseDecisionType.cautious;
    }
    if (inv.quantity > threshold && isSale) {
      return PurchaseDecisionType.bulkOpportunity;
    }
    return PurchaseDecisionType.none;
  }
}
