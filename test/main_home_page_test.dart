import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/home_page.dart';
import 'package:oouchi_stock/domain/entities/category.dart';

void main() {
  // ホーム画面を表示したときにタブバーが存在することを確認するテスト
  testWidgets('HomePage でタブが表示される',
      (WidgetTester tester) async {
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: HomePage(categories: categories)));
    await tester.pump();
    expect(find.byType(TabBar), findsOneWidget);
  });
}
