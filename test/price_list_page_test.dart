import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_list_page.dart';
import 'package:oouchi_stock/price_detail_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/domain/repositories/price_repository.dart';
import 'package:oouchi_stock/domain/usecases/watch_price_by_category.dart';
import 'package:oouchi_stock/presentation/viewmodels/price_category_list_viewmodel.dart';

void main() {
  testWidgets('カテゴリがない場合はメッセージと追加ボタンを表示', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PriceListPage()));
    await tester.pumpAndSettle();
    expect(find.text('カテゴリが登録されていません'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('設定メニューが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PriceListPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('PriceCategoryList がカードで表示される', (WidgetTester tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('同じ品種が複数登録されても全て表示される',
      (WidgetTester tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('情報アイコンタップで詳細画面へ遷移', (WidgetTester tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.info_outline).first);
    await tester.pumpAndSettle();
    expect(find.byType(PriceDetailPage), findsOneWidget);
  });

  testWidgets('削除アイコンが表示される', (WidgetTester tester) async {
    final repo = _FakeRepository();
    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsWidgets);
  });
}

class _FakeRepository implements PriceRepository {
  @override
  Future<String> addPriceInfo(PriceInfo info) async => '';

  @override
  Stream<List<PriceInfo>> watchByCategory(String category) => Stream.value([
        PriceInfo(
          id: '1',
          inventoryId: '1',
          checkedAt: DateTime.now(),
          category: category,
          itemType: '洗剤',
          itemName: 'テスト商品',
          count: 1,
          unit: '個',
          volume: 1,
          totalVolume: 1,
          regularPrice: 200,
          salePrice: 150,
          shop: '店',
          approvalUrl: '',
          memo: '',
          unitPrice: 150,
          expiry: DateTime.now().add(const Duration(days: 1)),
        ),
        PriceInfo(
          id: '2',
          inventoryId: '1',
          checkedAt: DateTime.now(),
          category: category,
          itemType: '洗剤',
          itemName: 'テスト商品2',
          count: 1,
          unit: '個',
          volume: 1,
          totalVolume: 1,
          regularPrice: 250,
          salePrice: 230,
          shop: '店',
          approvalUrl: '',
          memo: '',
          unitPrice: 230,
          expiry: DateTime.now().add(const Duration(days: 1)),
        )
      ]);

  @override
  Stream<List<PriceInfo>> watchByType(String category, String itemType) =>
      const Stream.empty();

  @override
  Future<void> deletePriceInfo(String id) async {}
}
