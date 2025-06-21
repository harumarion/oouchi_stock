import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/repositories/buy_list_repository.dart';
import 'package:oouchi_stock/domain/usecases/add_buy_item.dart';
import 'package:oouchi_stock/domain/services/auto_buy_list_service.dart';
import 'package:oouchi_stock/domain/services/purchase_decision_service.dart';

class _FakeRepo implements BuyListRepository {
  final List<BuyItem> items = [];
  @override
  Stream<List<BuyItem>> watchItems() async* {
    yield items;
  }

  @override
  Future<void> addItem(BuyItem item) async {
    items.add(item);
  }

  @override
  Future<void> removeItem(BuyItem item) async {
    items.removeWhere((e) => e.key == item.key);
  }
}

Inventory inv(double q) => Inventory(
      id: 'i',
      itemName: 'name',
      category: 'cat',
      itemType: 'type',
      quantity: q,
      unit: '個',
      createdAt: DateTime.now(),
    );

PriceInfo price(double sale, double regular) => PriceInfo(
      id: 'p',
      inventoryId: 'i',
      checkedAt: DateTime.now(),
      category: 'cat',
      itemType: 'type',
      itemName: 'name',
      count: 1,
      unit: '個',
      volume: 1,
      totalVolume: 1,
      regularPrice: regular,
      salePrice: sale,
      shop: '',
      approvalUrl: '',
      memo: '',
      unitPrice: sale,
      expiry: DateTime.now(),
    );

void main() {
  test('緊急在庫は自動追加される', () async {
    final repo = _FakeRepo();
    final service = AutoBuyListService(
        AddBuyItem(repo), PurchaseDecisionService(2));
    await service.process(inv(0), price(100, 120));
    expect(repo.items.length, 1);
  });

  test('在庫十分でセール中は自動追加されない', () async {
    final repo = _FakeRepo();
    final service = AutoBuyListService(
        AddBuyItem(repo), PurchaseDecisionService(2));
    await service.process(inv(5), price(80, 100));
    expect(repo.items.isEmpty, true);
  });

  test('在庫少でセール中は自動追加される', () async {
    final repo = _FakeRepo();
    final service = AutoBuyListService(
        AddBuyItem(repo), PurchaseDecisionService(2));
    await service.process(inv(1), price(80, 100));
    expect(repo.items.length, 1);
  });
}
