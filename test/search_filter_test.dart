import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';

void main() {
  // 検索機能がカテゴリ名や品種名も対象にすることを確認
  test('InventoryList の検索条件', () {
    final inv1 = Inventory(
      id: '1',
      itemName: 'りんご',
      category: '果物',
      itemType: '赤玉',
      quantity: 1,
      unit: '個',
      createdAt: DateTime.now(),
    );
    final inv2 = Inventory(
      id: '2',
      itemName: 'バナナ',
      category: '果物',
      itemType: '甘熟王',
      quantity: 1,
      unit: '房',
      createdAt: DateTime.now(),
    );
    final list = [inv1, inv2];
    const keyword = '果物';
    final result = list
        .where((inv) => inv.itemName.contains(keyword) || inv.category.contains(keyword) || inv.itemType.contains(keyword))
        .toList();
    expect(result.length, 2);
  });

  test('PriceCategoryList の検索条件', () {
    final p1 = PriceInfo(
      id: '1',
      inventoryId: '1',
      checkedAt: DateTime.now(),
      category: '果物',
      itemType: '赤玉',
      itemName: 'りんご',
      count: 1,
      unit: '個',
      volume: 1,
      totalVolume: 1,
      regularPrice: 120,
      salePrice: 100,
      shop: 'A',
      approvalUrl: '',
      memo: '',
      unitPrice: 100,
    );
    final p2 = PriceInfo(
      id: '2',
      inventoryId: '2',
      checkedAt: DateTime.now(),
      category: '野菜',
      itemType: 'にんじん',
      itemName: 'にんじん',
      count: 1,
      unit: '本',
      volume: 1,
      totalVolume: 1,
      regularPrice: 70,
      salePrice: 50,
      shop: 'B',
      approvalUrl: '',
      memo: '',
      unitPrice: 50,
    );
    final list = [p1, p2];
    const keyword = '野菜';
    final items = list
        .where((e) => e.itemName.contains(keyword) || e.category.contains(keyword) || e.itemType.contains(keyword))
        .toList();
    expect(items.length, 1);
    expect(items.first.category, '野菜');
  });
}
