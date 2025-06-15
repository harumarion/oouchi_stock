import '../entities/history_entry.dart';

abstract class PurchasePredictionStrategy {
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity);
}

class DummyPredictionStrategy implements PurchasePredictionStrategy {
  const DummyPredictionStrategy();
  @override
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity) {
    return now.add(const Duration(days: 7));
  }
}
