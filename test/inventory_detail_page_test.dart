import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oouchi_stock/inventory_detail_page.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:oouchi_stock/domain/entities/category.dart';
import 'package:oouchi_stock/domain/entities/inventory.dart';
import 'package:oouchi_stock/domain/entities/history_entry.dart';
import 'package:oouchi_stock/domain/repositories/inventory_repository.dart';

class _FakeRepository implements InventoryRepository {
  @override
  Stream<Inventory?> watchInventory(String inventoryId) => Stream.value(null);

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) => Stream.value([]);

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

class _DataRepository extends _FakeRepository {
  @override
  Stream<Inventory?> watchInventory(String inventoryId) =>
      Stream.value(Inventory(
        id: '1',
        itemName: 'テスト商品',
        category: '日用品',
        itemType: '一般',
        quantity: 1.0,
        unit: '個',
        monthlyConsumption: 0,
        createdAt: DateTime.now(),
      ));

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) =>
      Stream.value([
        HistoryEntry(
            timestamp: DateTime.now(),
            type: 'add',
            quantity: 1,
            before: 0,
            after: 1,
            diff: 1),
      ]);
}

void main() {
  testWidgets('InventoryDetailPage ローディング表示', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('データが取得できない場合にエラー表示', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        repository: _FakeRepository(),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Load error'), findsOneWidget);
  });

  testWidgets('詳細情報が左右に表示される', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        repository: _DataRepository(),
      ),
    ));
    await tester.pump();
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('一般'), findsOneWidget);
    expect(find.text('1.0個'), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);
    expect(find.text('追加'), findsOneWidget);
    expect(find.text('予測'), findsOneWidget);
  });

  testWidgets('履歴タイルに増減量が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        repository: _DataRepository(),
      ),
    ));
    await tester.pump();

    expect(find.textContaining('0.0 -> 1.0 (+1.0個)'), findsOneWidget);
  });

  testWidgets('履歴タイルのスタイルを確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InventoryDetailPage(
        inventoryId: '1',
        categories: [Category(id: 1, name: '日用品', createdAt: DateTime.now())],
        repository: _DataRepository(),
      ),
    ));
    await tester.pump();

    final text = tester.widget<Text>(find.text('追加'));
    expect(text.style?.fontSize, 18);

    final divider = tester.widget<Divider>(find.byType(Divider).first);
    expect(divider.color, Colors.grey.shade300);
  });
}
