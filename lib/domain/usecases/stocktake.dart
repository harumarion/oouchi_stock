import '../repositories/inventory_repository.dart';

/// 棚卸しを行うユースケース

class Stocktake {
  /// 在庫更新に利用するリポジトリ
  final InventoryRepository repository;

  Stocktake(this.repository);

  Future<void> call(
      String id, double before, double after, double diff) async {
    await repository.stocktake(id, before, after, diff);
  }
}
