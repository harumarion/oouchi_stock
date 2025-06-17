import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/settings_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('SettingsPage リスト表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: SettingsPage(categories: categories, onChanged: (_) {}),
    ));
    expect(find.text('カテゴリ設定'), findsOneWidget);
  });
}
