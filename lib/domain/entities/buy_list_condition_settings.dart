import 'package:shared_preferences/shared_preferences.dart';

/// 買い物予報の抽出条件の種類
enum BuyListConditionType { threshold, days, or }

/// 買い物予報の条件設定を保持するエンティティ
class BuyListConditionSettings {
  /// 条件タイプ
  final BuyListConditionType type;

  /// しきい値
  final double threshold;

  /// 日数条件
  final int days;
  const BuyListConditionSettings({
    required this.type,
    required this.threshold,
    required this.days,
  });
}

/// 設定を読み込む
Future<BuyListConditionSettings> loadBuyListConditionSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final typeIndex = prefs.getInt('buy_condition_type') ?? 0;
  final threshold = prefs.getDouble('buy_condition_threshold') ?? 0;
  final days = prefs.getInt('buy_condition_days') ?? 7;
  return BuyListConditionSettings(
    type: BuyListConditionType.values[typeIndex],
    threshold: threshold,
    days: days,
  );
}

/// 設定を保存する
Future<void> saveBuyListConditionSettings(BuyListConditionSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('buy_condition_type', settings.type.index);
  await prefs.setDouble('buy_condition_threshold', settings.threshold);
  await prefs.setInt('buy_condition_days', settings.days);
}
