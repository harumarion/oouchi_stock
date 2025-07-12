import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/domain/repositories/buy_list_repository.dart';
import 'package:oouchi_stock/domain/usecases/add_buy_item.dart';
import 'package:oouchi_stock/domain/usecases/auto_add_buy_item.dart';
import 'package:oouchi_stock/domain/usecases/purchase_decision.dart';

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
      volume: 1,
      totalVolume: q,
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
    final uc = AutoAddBuyItem(AddBuyItem(repo), PurchaseDecision(2,
        cautiousDays: 3, bestTimeDays: 3, discountPercent: 10));
    await uc(inv(0), price(100, 120));
    expect(repo.items.length, 1);
  });

  test('在庫十分でセール中は自動追加されない', () async {
    final repo = _FakeRepo();
    final uc = AutoAddBuyItem(AddBuyItem(repo), PurchaseDecision(2,
        cautiousDays: 3, bestTimeDays: 3, discountPercent: 10));
    await uc(inv(5), price(80, 100));
    expect(repo.items.isEmpty, true);
  });
}
