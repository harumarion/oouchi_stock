import '../repositories/inventory_repository.dart';

class UpdateQuantity {
  final InventoryRepository repository;
  UpdateQuantity(this.repository);

  Future<void> call(String id, double amount, String type) async {
    await repository.updateQuantity(id, amount, type);
  }
}
