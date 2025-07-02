import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';

void main() {
  test('同じIDのInventoryは等価', () {
    final now = DateTime(2020);
    final a = Inventory(
      id: '1',
      itemName: 'A',
      category: 'cat',
      itemType: 'type',
      quantity: 1,
      unit: '個',
      createdAt: now,
    );
    final b = Inventory(
      id: '1',
      itemName: 'B',
      category: 'cat',
      itemType: 'type',
      quantity: 2,
      unit: '本',
      createdAt: now,
    );
    expect(a, equals(b));
    expect({a, b}.length, 1);
  });
}
