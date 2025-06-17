import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

class WatchPriceByType {
  final PriceRepository repository;
  WatchPriceByType(this.repository);

  Stream<List<PriceInfo>> call(String category, String type) {
    return repository.watchByType(category, type);
  }
}
