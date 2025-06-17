import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/edit_category_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('EditCategoryPage 初期値表示', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(MaterialApp(home: EditCategoryPage(category: cat)));
    expect(find.text('日用品'), findsOneWidget);
  });
}
