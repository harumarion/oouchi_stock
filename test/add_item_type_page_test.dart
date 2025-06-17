import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/add_item_type_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('AddItemTypePage が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddItemTypePage(
          categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        ),
      ),
    );
    expect(find.byType(DropdownButtonFormField<Category>), findsOneWidget);
  });
}
