import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/category_settings_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('ドラッグで並び替えができる', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: 'A', createdAt: DateTime.now()),
      Category(id: 2, name: 'B', createdAt: DateTime.now()),
    ];
    List<Category>? changed;
    await tester.pumpWidget(MaterialApp(
      home: CategorySettingsPage(
        initial: categories,
        onChanged: (v) => changed = v,
      ),
    ));

    await tester.drag(find.byType(ReorderableDragStartListener).first, const Offset(0, 50));
    await tester.pumpAndSettle();

    expect(changed?.map((e) => e.id).toList(), [2, 1]);
  });
}
