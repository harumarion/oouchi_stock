import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

class AddBuyItem {
  final BuyListRepository repository;
  AddBuyItem(this.repository);
  Future<void> call(BuyItem item) => repository.addItem(item);
}
