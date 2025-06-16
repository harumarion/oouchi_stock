import '../entities/price_info.dart';
import '../repositories/price_repository.dart';

class AddPriceInfo {
  final PriceRepository repository;
  AddPriceInfo(this.repository);

  Future<void> call(PriceInfo info) async {
    await repository.addPriceInfo(info);
  }
}
