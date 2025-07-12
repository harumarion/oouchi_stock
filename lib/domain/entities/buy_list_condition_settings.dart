import "../entities/inventory.dart";
import "../repositories/inventory_repository.dart";
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

/// 在庫から残り日数を計算するヘルパー
int _daysLeftFromInventory(Inventory inv) {
  if (inv.monthlyConsumption <= 0) return 9999;
  return (inv.totalVolume / inv.monthlyConsumption * 30).ceil();
}

/// 買い物予報抽出用ストラテジー
abstract class BuyListStrategy {
  Stream<List<Inventory>> watch(InventoryRepository repository);
}

/// 在庫数がしきい値以下の場合に表示するストラテジー
class ThresholdStrategy implements BuyListStrategy {
  /// 在庫数のしきい値
  final double threshold;
  ThresholdStrategy(this.threshold);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) {
    return repository.watchNeedsBuy(threshold);
  }
}

/// 予測日が指定日数以内の場合に表示するストラテジー
class PredictionDaysStrategy implements BuyListStrategy {
  /// 予測日数の上限
  final int days;
  PredictionDaysStrategy(this.days);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) async* {
    final list = await repository.fetchAll();
    final result = <Inventory>[];
    for (final inv in list) {
      final d = _daysLeftFromInventory(inv);
      if (d <= days) {
        result.add(inv);
      }
    }
    yield result;
  }
}

/// しきい値条件または日数条件のどちらかを満たすストラテジー
class OrStrategy implements BuyListStrategy {
  /// 在庫数のしきい値
  final double threshold;
  /// 予測日数の上限
  final int days;
  OrStrategy(this.threshold, this.days);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) async* {
    final list = await repository.fetchAll();
    final result = <Inventory>[];
    for (final inv in list) {
      final d = _daysLeftFromInventory(inv);
      if (inv.quantity <= threshold || d <= days) {
        result.add(inv);
      }
    }
    yield result;
  }
}

/// 設定内容に応じたストラテジーを生成する
BuyListStrategy createStrategy(BuyListConditionSettings settings) {
  switch (settings.type) {
    case BuyListConditionType.threshold:
      return ThresholdStrategy(settings.threshold);
    case BuyListConditionType.days:
      return PredictionDaysStrategy(settings.days);
    case BuyListConditionType.or:
      return OrStrategy(settings.threshold, settings.days);
  }
}
