import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/item_type_settings_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('ItemTypeSettingsPage が表示される', (WidgetTester tester) async {
    final cat = Category(id: 1, name: '日用品', createdAt: DateTime.now());
    await tester.pumpWidget(MaterialApp(
      home: ItemTypeSettingsPage(categories: [cat]),
    ));
    // タブと FAB が表示されていることを確認
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
