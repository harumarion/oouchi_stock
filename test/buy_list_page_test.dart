import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/buy_list_page.dart';
import 'package:oouchi_stock/widgets/buy_list_card.dart';
import 'package:oouchi_stock/widgets/category_segmented_button.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/presentation/viewmodels/buy_list_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';

class _FakeRepository implements InventoryRepository {
  @override
  Stream<Inventory?> watchInventory(String inventoryId) => Stream.value(Inventory(
        id: 'inv1',
        itemName: 'テスト',
        category: '日用品',
        itemType: '一般',
        quantity: 1.0,
        volume: 1,
        totalVolume: 1,
        unit: '個',
        monthlyConsumption: 0,
        createdAt: DateTime.now(),
      ));

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) =>
      Stream.value([HistoryEntry('add', 1.0, DateTime.now())]);

  // 以下のメソッドはテストでは使用しない
  @override
  Future<List<Inventory>> fetchAll() async => [];
  @override
  Future<String> addInventory(Inventory inventory) async => '';
  @override
  Future<void> updateQuantity(String id, double amount, String type) async {}
  @override
  Future<void> updateInventory(Inventory inventory) async {}
  @override
  Future<void> stocktake(String id, double before, double after, double diff) async {}
  @override
  Future<void> deleteInventory(String id) async {}
  @override
  Stream<List<Inventory>> watchByCategory(String category) => const Stream.empty();
  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) => const Stream.empty();
}

void main() {
  testWidgets('BuyListPage 追加入力欄表示', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pump();
    expect(find.byType(SearchAnchor), findsOneWidget);
    // 共通カテゴリ切り替えウィジェットが表示されること
    expect(find.byType(CategorySegmentedButton), findsOneWidget);
  });

  testWidgets('設定メニューボタンが表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final categories = [Category(id: 1, name: 'X', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('削除時に数量入力ダイアログが表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'buy_list_items': ['|テスト|inv1']
    });
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(home: BuyListPage(categories: categories)));
    await tester.pumpAndSettle();
    expect(find.text('テスト / 一般'), findsOneWidget);

    await tester.drag(find.text('テスト / 一般'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('在庫数と残り日数が表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'buy_list_items': ['|テスト|inv1']
    });
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: BuyListPage(
        categories: categories,
        viewModel: BuyListViewModel(repository: _FakeRepository()),
      ),
    ));
    await tester.pumpAndSettle();
    // 残量表示が総容量→単位の順になっているか確認
    expect(find.textContaining('残り1.0(1.0個)'), findsOneWidget);
    expect(find.textContaining('あと7日'), findsOneWidget);
  });

  testWidgets('BuyListCard ウィジェットが表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'buy_list_items': ['|テスト|inv1']
    });
    final categories = [Category(id: 1, name: '日用品', createdAt: DateTime.now())];
    await tester.pumpWidget(MaterialApp(
      home: BuyListPage(
        categories: categories,
        viewModel: BuyListViewModel(repository: _FakeRepository()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(BuyListCard), findsOneWidget);
  });
}
