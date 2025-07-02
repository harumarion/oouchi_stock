import 'package:shared_preferences/shared_preferences.dart';

/// 購入判定に使用するしきい値設定を保持するエンティティ
class PurchaseDecisionSettings {
  /// 慎重判定となる残り日数
  final int cautiousDays; // _cautiousDays

  /// 最も買い時と判定する残り日数
  final int bestTimeDays; // _bestTimeDays

  /// セール価格が通常価格より何パーセント安いと買い時とするか
  final double discountPercent; // _discountPercent

  const PurchaseDecisionSettings({
    required this.cautiousDays,
    required this.bestTimeDays,
    required this.discountPercent,
  });
}

/// 設定を読み込む
Future<PurchaseDecisionSettings> loadPurchaseDecisionSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final cautious = prefs.getInt('pd_cautious_days') ?? 3;
  final best = prefs.getInt('pd_best_days') ?? 3;
  final percent = prefs.getDouble('pd_discount_percent') ?? 10.0;
  return PurchaseDecisionSettings(
    cautiousDays: cautious,
    bestTimeDays: best,
    discountPercent: percent,
  );
}

/// 設定を保存する
Future<void> savePurchaseDecisionSettings(
    PurchaseDecisionSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('pd_cautious_days', settings.cautiousDays);
  await prefs.setInt('pd_best_days', settings.bestTimeDays);
  await prefs.setDouble('pd_discount_percent', settings.discountPercent);
}
