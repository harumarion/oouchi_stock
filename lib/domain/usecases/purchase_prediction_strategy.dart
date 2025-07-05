// 購入予測を計算するユースケース群
import '../entities/history_entry.dart';

/// 購入予測日を計算するストラテジー
abstract class PurchasePredictionStrategy {
  /// [now] 時点での履歴と残量から予測購入日を返す
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity);
}

/// 固定で1週間後を返すダミーストラテジー
class DummyPredictionStrategy implements PurchasePredictionStrategy {
  const DummyPredictionStrategy();
  @override
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity) {
    return now.add(const Duration(days: 7));
  }
}

/// 履歴から月あたりの消費量を計算し、予測日を返すストラテジー
class MonthlyConsumptionStrategy implements PurchasePredictionStrategy {
  const MonthlyConsumptionStrategy();
  @override
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity) {
    final monthAgo = now.subtract(const Duration(days: 30));
    double used = 0;
    for (final h in history) {
      if (h.type == 'used' && h.timestamp.isAfter(monthAgo)) {
        used += h.quantity;
      }
    }
    if (used == 0) return now;
    final months = quantity / used;
    return now.add(Duration(days: (months * 30).ceil()));
  }
}
