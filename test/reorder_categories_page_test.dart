import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/reorder_categories_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('戻るボタンでも並び順が保存される', (WidgetTester tester) async {
    final cats = [
      Category(id: 1, name: 'A', createdAt: DateTime.now()),
      Category(id: 2, name: 'B', createdAt: DateTime.now()),
    ];
    List<Category>? result;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReorderCategoriesPage(categories: cats),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final firstItem = find.text('A');
    await tester.drag(firstItem, const Offset(0, 50));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(result?.map((c) => c.id).toList(), [2, 1]);
  });
}
