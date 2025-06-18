import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';
import '../entities/history_entry.dart';
import '../services/purchase_prediction_strategy.dart';
import '../entities/buy_list_condition_settings.dart';

/// 履歴から現在の在庫数量を計算するヘルパー
double _currentQuantity(List<HistoryEntry> history) {
  if (history.isEmpty) return 0;
  double total = 0;
  for (final h in history.reversed) {
    if (h.type == 'stocktake') {
      total = h.after;
    } else if (h.type == 'add' || h.type == 'bought') {
      total += h.quantity;
    } else if (h.type == 'used') {
      total -= h.quantity;
    }
  }
  return total;
}

/// 買うべきリスト抽出用ストラテジー
abstract class BuyListStrategy {
  Stream<List<Inventory>> watch(InventoryRepository repository);
}

/// 在庫数がしきい値以下の場合に表示するストラテジー
class ThresholdStrategy implements BuyListStrategy {
  final double threshold;
  ThresholdStrategy(this.threshold);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) {
    return repository.watchNeedsBuy(threshold);
  }
}

/// 予測日が指定日数以内の場合に表示するストラテジー
class PredictionDaysStrategy implements BuyListStrategy {
  final int days;
  final PurchasePredictionStrategy prediction;
  PredictionDaysStrategy(this.days, this.prediction);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) async* {
    final list = await repository.fetchAll();
    final result = <Inventory>[];
    for (final inv in list) {
      final history = await repository.watchHistory(inv.id).first;
      final predicted =
          prediction.predict(DateTime.now(), history, _currentQuantity(history));
      if (predicted.difference(DateTime.now()).inDays <= days) {
        result.add(inv);
      }
    }
    yield result;
  }
}

/// しきい値条件または日数条件のどちらかを満たすストラテジー
class OrStrategy implements BuyListStrategy {
  final double threshold;
  final int days;
  final PurchasePredictionStrategy prediction;
  OrStrategy(this.threshold, this.days, this.prediction);
  @override
  Stream<List<Inventory>> watch(InventoryRepository repository) async* {
    final list = await repository.fetchAll();
    final result = <Inventory>[];
    for (final inv in list) {
      final history = await repository.watchHistory(inv.id).first;
      final predicted =
          prediction.predict(DateTime.now(), history, _currentQuantity(history));
      if (inv.quantity <= threshold ||
          predicted.difference(DateTime.now()).inDays <= days) {
        result.add(inv);
      }
    }
    yield result;
  }
}

/// 設定から適切なストラテジーを生成する
BuyListStrategy createStrategy(BuyListConditionSettings settings) {
  const prediction = DummyPredictionStrategy();
  switch (settings.type) {
    case BuyListConditionType.threshold:
      return ThresholdStrategy(settings.threshold);
    case BuyListConditionType.days:
      return PredictionDaysStrategy(settings.days, prediction);
    case BuyListConditionType.or:
      return OrStrategy(settings.threshold, settings.days, prediction);
  }
}
