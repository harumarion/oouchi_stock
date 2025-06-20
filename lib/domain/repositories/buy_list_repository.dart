import '../entities/buy_item.dart';

abstract class BuyListRepository {
  Stream<List<BuyItem>> watchItems();
  Future<void> addItem(BuyItem item);
  Future<void> removeItem(BuyItem item);
}
