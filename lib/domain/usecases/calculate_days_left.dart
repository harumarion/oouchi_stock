import '../entities/inventory.dart';
import '../repositories/inventory_repository.dart';

/// 在庫履歴から残り日数を計算するユースケース
class CalculateDaysLeft {
  /// 在庫データ取得用リポジトリ
  final InventoryRepository repository;

  CalculateDaysLeft(this.repository);

  /// [inventory] の残量がなくなるまでの日数を返す
  Future<int> call(Inventory inventory) async {
    if (inventory.monthlyConsumption <= 0) return 9999;
    final days =
        (inventory.totalVolume / inventory.monthlyConsumption * 30).ceil();
    return days;
  }
}
