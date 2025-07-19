import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/sale_list_page.dart';
import 'package:oouchi_stock/widgets/sale_item_card.dart';

void main() {
  // セール情報一覧画面を開いた直後の表示をテストする
  testWidgets('SaleListPage 初期表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SaleListPage()));
    expect(find.byType(AppBar), findsOneWidget);
    // 検索欄として SearchBar が存在するか確認
    expect(find.byType(SearchBar), findsOneWidget);
    // サンプルデータ削除に伴いカードは表示されない
    expect(find.byType(SaleItemCard), findsNothing);
    // 通知アイコンボタンが表示されていることを確認
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    // 並び替えメニューが存在することを確認
    expect(find.byType(PopupMenuButton), findsOneWidget);
  });
}
