import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

class WatchPriceByCategory {
  final PriceRepository repository;
  WatchPriceByCategory(this.repository);

  Stream<List<PriceInfo>> call(String category) {
    return repository.watchByCategory(category);
  }
}
