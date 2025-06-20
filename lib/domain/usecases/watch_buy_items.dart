import '../entities/buy_item.dart';
import '../repositories/buy_list_repository.dart';

class WatchBuyItems {
  final BuyListRepository repository;
  WatchBuyItems(this.repository);
  Stream<List<BuyItem>> call() => repository.watchItems();
}
