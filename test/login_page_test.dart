import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/login_page.dart';

void main() {
  // ローカライズ未読み込みでもクラッシュしないか確認
  testWidgets('LoginPage 表示テスト', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(onLoggedIn: () {}),
    ));
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
