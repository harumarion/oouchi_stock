import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';

import 'add_price_page.dart';
import 'add_category_page.dart';
import 'widgets/settings_menu_button.dart';
import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/price_info.dart';
import 'domain/entities/category_order.dart';
import 'domain/usecases/watch_price_by_category.dart';
import 'price_history_page.dart';
import 'main.dart';

// セール情報管理画面

class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends State<PriceListPage> {
  // カテゴリ一覧を保持する _categories
  List<Category> _categories = [];
  // Firestore からの読み込み完了状態を示す _loaded
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    userCollection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      var list = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
        );
      }).toList();
      list = await applyCategoryOrder(list);
      setState(() {
        _categories = list;
        _loaded = true;
      });
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceManagementTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリが存在しない場合は追加ボタンと案内テキストを表示
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceManagementTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // カテゴリ未登録メッセージ
              Text(AppLocalizations.of(context)!.noCategories),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // カテゴリ追加画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCategory),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.priceManagementTitle),
          actions: [
            // 共通の設定メニューボタンを使用
            SettingsMenuButton(
              categories: _categories,
              onCategoriesChanged: (l) {},
              onLocaleChanged: (l) =>
                  context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
              onConditionChanged: () {},
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final c in _categories)
                // 最大3件までを幅いっぱいに表示
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Tab(text: c.name),
                )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in _categories) PriceCategoryList(category: c.name)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // セール情報追加画面を開く
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPricePage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// セール情報管理画面の各タブに表示される
// カテゴリ別セール一覧ウィジェット
class PriceCategoryList extends StatefulWidget {
  final String category; // 表示対象カテゴリ名
  final WatchPriceByCategory _watch; // セール情報取得ユースケース

  /// [watch] はテスト用に差し替え可能
  PriceCategoryList({
    super.key,
    required this.category,
    WatchPriceByCategory? watch,
  }) : _watch = watch ?? WatchPriceByCategory(PriceRepositoryImpl());

  @override
  State<PriceCategoryList> createState() => _PriceCategoryListState();
}

class _PriceCategoryListState extends State<PriceCategoryList> {
  // 検索文字列を保持する _search
  String _search = '';
  // 並び替え条件を表す _sort。デフォルトは最終更新順
  String _sort = 'updated';
  // 検索欄のテキストコントローラー _controller
  final TextEditingController _controller = TextEditingController();
  // 期限切れも表示するかどうかを示す _showExpired
  bool _showExpired = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ユースケースからセール情報を取得して表示
    final watch = widget._watch;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 検索バー
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchHint,
                  ),
                  // 入力文字列に応じてリストをフィルタリング
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              // 並び替えドロップダウン。選択変更で並び替えを実行
              DropdownButton<String>(
                value: _sort,
                onChanged: (v) => setState(() => _sort = v!),
                items: [
                  DropdownMenuItem(
                    value: 'alphabet',
                    child: Text(AppLocalizations.of(context)!.sortAlphabet),
                  ),
                  DropdownMenuItem(
                    value: 'updated',
                    child: Text(AppLocalizations.of(context)!.sortUpdated),
                  ),
                  DropdownMenuItem(
                    value: 'unitPrice',
                    child: Text(AppLocalizations.of(context)!.sortUnitPrice),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.showExpired),
                  Switch(
                    value: _showExpired,
                    onChanged: (v) => setState(() => _showExpired = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<PriceInfo>>(
            stream: watch(widget.category),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final err = snapshot.error?.toString() ?? 'unknown';
                return Center(
                    child: Text(AppLocalizations.of(context)!.loadError(err)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snapshot.data!;
              final Map<String, PriceInfo> map = {};
              for (final p in list) {
                final current = map[p.itemType];
                if (current == null || p.unitPrice < current.unitPrice) {
                  map[p.itemType] = p;
                }
              }
              // 商品名だけでなくカテゴリ名・品種名も検索対象に含める
              var items = map.values
                  .where((e) =>
                      e.itemName.contains(_search) ||
                      e.category.contains(_search) ||
                      e.itemType.contains(_search))
                  .where((e) => _showExpired ||
                      e.expiry.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                  .toList();
              // 選択された並び替え順に従ってソート
              // 並び替えの条件に応じてソートを実行
              if (_sort == 'alphabet') {
                items.sort((a, b) => a.itemType.compareTo(b.itemType));
              } else if (_sort == 'unitPrice') {
                items.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
              } else {
                items.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
              }
              return ListView.builder(
                // カード型リストでセール情報を表示
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];
                  final diff = p.regularPrice - p.salePrice;
                  return InkWell(
                    onTap: () {
                      // タップでセール情報履歴画面へ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PriceHistoryPage(
                            category: widget.category,
                            itemType: p.itemType,
                            itemName: p.itemName,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.itemType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(p.itemName),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.expiry(_formatDate(p.expiry))),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.regularPriceLabel(p.regularPrice.toStringAsFixed(0))),
                            Text(AppLocalizations.of(context)!.salePriceLabel(p.salePrice.toStringAsFixed(0))),
                            Text(AppLocalizations.of(context)!.priceDiffLabel(diff.toStringAsFixed(0))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 日付を表示用の文字列に変換
  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }
}
