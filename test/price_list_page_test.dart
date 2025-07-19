import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/price_list_page.dart';
import 'package:oouchi_stock/price_detail_page.dart';
import 'package:oouchi_stock/domain/entities/price_info.dart';
import 'package:oouchi_stock/widgets/card_menu_button.dart';
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
    expect(find.byType(CardMenuButton), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('PriceCategoryList が ListTile で表示される', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('同じ品種が複数登録されても全て表示される',
      (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('カードタップで詳細画面へ遷移', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(find.byType(PriceDetailPage), findsOneWidget);
  });

  testWidgets('カードをスワイプして削除できる', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    expect(find.byType(Dismissible), findsWidgets);
  });

  // カード右上のメニューボタン配置を確認するテスト
  testWidgets('メニューボタンが右側に配置される', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    final tile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(tile.leading, isNull);
    expect(tile.trailing, isA<Row>());
  });

  // メニューボタン押下で「買い物リストへ追加」のみ表示されるかテスト
  testWidgets('メニューに買い物リスト追加のみ表示', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('買い物リストへ追加'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('価格情報が1行表示され単価が次行に表示される',
      (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ja'),
      home: PriceCategoryList(
        category: '日用品',
        viewModel: PriceCategoryListViewModel(
          category: '日用品',
          watch: WatchPriceByCategory(repo),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('通常価格: 200 セール価格: 150 差額: -50'), findsOneWidget);
    expect(find.text('単価: 150.00'), findsOneWidget);
  });

  testWidgets('カテゴリ変更でリストが更新される', (WidgetTester tester) async {
    final repoA = _FakeRepository('商品A');
    final repoB = _FakeRepository('商品B');
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        key: key,
        category: 'A',
        viewModel: PriceCategoryListViewModel(
          category: 'A',
          watch: WatchPriceByCategory(repoA),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('商品A'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: PriceCategoryList(
        key: key,
        category: 'B',
        viewModel: PriceCategoryListViewModel(
          category: 'B',
          watch: WatchPriceByCategory(repoB),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('商品B'), findsOneWidget);
  });

  testWidgets('検索バーとリストの横幅が一致する', (WidgetTester tester) async {
    final repo = _FakeRepository('テスト商品');
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
    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.padding, const EdgeInsets.fromLTRB(16, 16, 16, 96));
  });
}

class _FakeRepository implements PriceRepository {
  _FakeRepository(this.itemName);
  final String itemName;

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
          itemName: itemName,
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
        )
      ]);

  @override
  Stream<List<PriceInfo>> watchByType(String category, String itemType) =>
      const Stream.empty();

  @override
  Future<void> deletePriceInfo(String id) async {}
}
