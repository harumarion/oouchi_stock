import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

/// セール情報を追加するユースケース
class AddPriceInfo {
  /// データ保存先リポジトリ
  final PriceRepository repository;

  AddPriceInfo(this.repository);

  Future<void> call(PriceInfo info) async {
    await repository.addPriceInfo(info);
  }
}
