import '../repositories/price_repository.dart';

/// セール情報を削除するユースケース
class DeletePriceInfo {
  /// データ削除に利用するリポジトリ
  final PriceRepository repository;

  DeletePriceInfo(this.repository);

  Future<void> call(String id) async {
    await repository.deletePriceInfo(id);
  }
}
