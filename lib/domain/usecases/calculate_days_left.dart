import '../entities/inventory.dart';
import '../services/purchase_prediction_strategy.dart';
import '../repositories/inventory_repository.dart';

/// 在庫履歴から残り日数を計算するユースケース
class CalculateDaysLeft {
  /// 在庫データ取得用リポジトリ
  final InventoryRepository repository;

  /// 購入予測アルゴリズム
  final PurchasePredictionStrategy strategy;

  CalculateDaysLeft(this.repository, this.strategy);

  /// [inventory] の残量がなくなるまでの日数を返す
  Future<int> call(Inventory inventory) async {
    final history = await repository.watchHistory(inventory.id).first;
    double quantity = 0;
    for (final h in history.reversed) {
      if (h.type == 'stocktake') {
        quantity = h.after;
      } else if (h.type == 'add' || h.type == 'bought') {
        quantity += h.quantity;
      } else if (h.type == 'used') {
        quantity -= h.quantity;
      }
    }
    final predicted = strategy.predict(DateTime.now(), history, quantity);
    return predicted.difference(DateTime.now()).inDays;
  }
}
