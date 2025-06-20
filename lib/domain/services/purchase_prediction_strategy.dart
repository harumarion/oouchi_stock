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
