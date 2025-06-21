import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/services/purchase_decision_service.dart';

void main() {
  // 購入判定サービスのテスト
  final service = PurchaseDecisionService(2);

  Inventory invWith(double q) => Inventory(
        id: 'id',
        itemName: 'name',
        category: 'cat',
        itemType: 'type',
        quantity: q,
        unit: '個',
        createdAt: DateTime.now(),
      );

  PriceInfo price({double sale = 100, double regular = 120}) => PriceInfo(
        id: 'p',
        inventoryId: 'id',
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

  test('在庫ゼロは緊急対応', () {
    expect(service.decide(invWith(0), price()),
        PurchaseDecisionType.emergency);
  });

  test('在庫少で価格高めは安心対応', () {
    expect(service.decide(invWith(1), price(sale: 150, regular: 100)),
        PurchaseDecisionType.cautious);
  });

  test('在庫十分でセール中はまとめ買いチャンス', () {
    expect(service.decide(invWith(3), price(sale: 80, regular: 100)),
        PurchaseDecisionType.bulkOpportunity);
  });

  test('在庫少でセール中は最も買い時', () {
    expect(service.decide(invWith(1), price(sale: 80, regular: 100)),
        PurchaseDecisionType.bestTime);
  });
}
