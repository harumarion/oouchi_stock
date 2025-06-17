import '../repositories/price_repository.dart';

class DeletePriceInfo {
  final PriceRepository repository;
  DeletePriceInfo(this.repository);

  Future<void> call(String id) async {
    await repository.deletePriceInfo(id);
  }
}
