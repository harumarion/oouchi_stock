import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

class RemoveBuyItem {
  final BuyListRepository repository;
  RemoveBuyItem(this.repository);
  Future<void> call(BuyItem item) => repository.removeItem(item);
}
