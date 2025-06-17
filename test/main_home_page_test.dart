import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/main.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('HomePage タブ表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: HomePage(categories: categories)));
    expect(find.text('日用品'), findsOneWidget);
  });
}
