import '../entities/inventory.dart';
import '../entities/price_info.dart';

/// 購入判定の種類
/// emergency: 在庫ゼロ
/// cautious: 残り日数が設定以下
/// bulkOpportunity: 在庫十分でセール
/// bestTime: 残り日数が設定以下かつ十分な値引き
/// none: 条件に当てはまらない場合
enum PurchaseDecisionType { none, emergency, cautious, bulkOpportunity, bestTime }

/// 在庫量と価格情報から購入判定を行うサービス
/// 在庫数と価格を比較し、買い時かどうかを分類する
class PurchaseDecisionService {
  /// 在庫量のしきい値。ここより少ないと「在庫少」とみなす
  final double threshold;

  /// 慎重判定となる残り日数
  final int cautiousDays;

  /// 買い時判定となる残り日数
  final int bestTimeDays;

  /// セール価格が通常価格より何パーセント安いと買い時とするか
  final double discountPercent;

  PurchaseDecisionService(
    this.threshold, {
    required this.cautiousDays,
    required this.bestTimeDays,
    required this.discountPercent,
  });

  /// 残り日数を計算する
  /// 月間消費量が 0 以下の場合は計算できないため 9999 を返す
  int _daysLeft(Inventory inv) {
    if (inv.monthlyConsumption <= 0) return 9999;
    return (inv.quantity / inv.monthlyConsumption * 30).ceil();
  }

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
    // 値引き率
    final discount = price != null
        ? (price.regularPrice - price.salePrice) / price.regularPrice * 100
        : 0.0;

    final days = _daysLeft(inv);

    if (days <= bestTimeDays &&
        isSale &&
        discount >= discountPercent) {
      // 残り日数が少なく十分な値引きがある
      return PurchaseDecisionType.bestTime;
    }

    if (days <= cautiousDays) {
      // 残り日数がしきい値以下
      return PurchaseDecisionType.cautious;
    }

    if (inv.quantity > threshold && isSale) {
      // 在庫十分でセール中
      return PurchaseDecisionType.bulkOpportunity;
    }
    // どの条件にも当てはまらない場合は購入不要
    return PurchaseDecisionType.none;
  }
}
