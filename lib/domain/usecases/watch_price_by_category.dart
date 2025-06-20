import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

/// カテゴリ別にセール情報を監視するユースケース
class WatchPriceByCategory {
  /// データ取得元リポジトリ
  final PriceRepository repository;

  WatchPriceByCategory(this.repository);

  Stream<List<PriceInfo>> call(String category) {
    return repository.watchByCategory(category);
  }
}
