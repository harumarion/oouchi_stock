import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

/// セール情報を更新するユースケース
class UpdatePriceInfo {
  /// 利用するリポジトリ
  final PriceRepository repository;

  UpdatePriceInfo(this.repository);

  /// セール情報を更新する
  Future<void> call(PriceInfo info) async {
    await repository.updatePriceInfo(info);
  }
}
