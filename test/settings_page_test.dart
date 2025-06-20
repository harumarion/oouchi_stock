import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/settings_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  testWidgets('SettingsPage リスト表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: SettingsPage(
        categories: categories,
        onChanged: (_) {},
        onLocaleChanged: (_) {},
        onConditionChanged: () {},
      ),
    ));
    expect(find.text('カテゴリ設定'), findsOneWidget);
    expect(find.text('言語'), findsOneWidget);
    expect(find.text('買い物予報条件設定'), findsOneWidget);
    expect(find.byKey(const Key('backupTile')), findsOneWidget);
    expect(find.byKey(const Key('restoreTile')), findsOneWidget);
  });

  testWidgets('バックアップ確認ダイアログ表示', (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: SettingsPage(
        categories: categories,
        onChanged: (_) {},
        onLocaleChanged: (_) {},
        onConditionChanged: () {},
      ),
    ));
    // バックアップボタンをタップすると確認ダイアログが表示される
    await tester.tap(find.text('バックアップ'));
    await tester.pumpAndSettle();
    expect(find.text('バックアップを作成しますか?'), findsOneWidget);
  });
}
