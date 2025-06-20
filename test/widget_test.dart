// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oouchi_stock/main.dart';
import 'firebase_test_utils.dart';
import 'package:oouchi_stock/add_category_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('アプリが起動する', (WidgetTester tester) async {
    final categories = [
      Category(id: 1, name: '日用品', createdAt: DateTime.now())
    ];
    await tester.pumpWidget(MyApp(initialCategories: categories));
    expect(find.text('おうちストック'), findsOneWidget);
  });

  testWidgets('カテゴリ名未入力で保存するとバリデーションエラーが表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCategoryPage()));
    await tester.tap(find.text('保存'));
    await tester.pump();
    expect(find.text('必須項目です'), findsOneWidget);
  });

  test('AppTheme のプライマリカラーが設定されている', () {
    final theme = AppTheme.lightTheme;
    expect(theme.colorScheme.primary, AppTheme.primaryColor);
  });
}
