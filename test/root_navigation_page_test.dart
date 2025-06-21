import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/root_navigation_page.dart';

void main() {
  testWidgets('下部メニューが4個表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RootNavigationPage()));
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bar.items.length, 4);
    // 最後のメニューラベルがセール情報追加か確認
    expect(bar.items.last.label, 'セール情報追加');
  });
}
