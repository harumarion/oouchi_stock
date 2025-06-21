import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';
import '../entities/buy_list_condition_settings.dart';

/// 在庫から残り日数を計算するヘルパー
int _daysLeftFromInventory(Inventory inv) {
  if (inv.monthlyConsumption <= 0) return 9999;
  return (inv.quantity / inv.monthlyConsumption * 30).ceil();
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
