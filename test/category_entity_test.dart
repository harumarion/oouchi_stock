import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  test('同じIDのCategoryは等価', () {
    final a = Category(id: 1, name: 'A', createdAt: DateTime(2020));
    final b = Category(id: 1, name: 'B', createdAt: DateTime(2021));
    expect(a, equals(b));
    expect({a, b}.length, 1);
  });
}
