import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

/// カテゴリと品種でセール情報を監視するユースケース
class WatchPriceByType {
  /// データ取得元リポジトリ
  final PriceRepository repository;

  WatchPriceByType(this.repository);

  Stream<List<PriceInfo>> call(String category, String type) {
    return repository.watchByType(category, type);
  }
}
