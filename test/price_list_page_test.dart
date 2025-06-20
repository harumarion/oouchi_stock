import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_list_page.dart';

void main() {
  testWidgets('PriceListPage 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PriceListPage()));
    expect(find.byType(AppBar), findsOneWidget);
    // 検索バーが表示されるか確認
    expect(find.byType(TextField), findsWidgets);
    // 表の列数が6であることを確認
    final dataTable = tester.widget<DataTable>(find.byType(DataTable).first);
    expect(dataTable.columns.length, 6);
  });

  testWidgets('設定メニューが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PriceListPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });
}
