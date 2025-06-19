import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'price_list_page.dart';
import 'inventory_page.dart';
import 'settings_page.dart';
import 'inventory_detail_page.dart';
import 'widgets/inventory_card.dart';
import 'main.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category_order.dart';
import 'domain/services/buy_list_strategy.dart';
import 'domain/entities/buy_list_condition_settings.dart';

/// ホーム画面。起動時に表示され、買い物リストを管理する。
class HomePage extends StatefulWidget {
  /// 起動時に受け取るカテゴリ一覧。null の場合は Firestore から取得する
  final List<Category>? categories;
  const HomePage({super.key, this.categories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Firestore から取得したカテゴリ一覧
  List<Category> _categories = [];
  /// カテゴリが読み込み済みかどうかのフラグ
  bool _categoriesLoaded = false;
  /// カテゴリコレクションを監視するストリーム購読
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;
  /// 買い物予報の条件設定
  BuyListConditionSettings? _conditionSettings;

  /// 設定画面から戻った際にカテゴリリストを更新する
  void _updateCategories(List<Category> list) {
    setState(() {
      _categories = List.from(list);
      _categoriesLoaded = true;
    });
  }

  Future<void> _loadCondition() async {
    // 設定画面から戻った際にも呼ばれ、買い物リスト条件を再読込する
    final s = await loadBuyListConditionSettings();
    setState(() => _conditionSettings = s);
  }

  @override
  void initState() {
    super.initState();
    _loadCondition();
    if (widget.categories != null) {
      _categories = List.from(widget.categories!);
      applyCategoryOrder(_categories).then((list) {
        setState(() {
          _categories = list;
          _categoriesLoaded = true;
        });
      });
    } else {
      // Firestore からカテゴリ一覧を取得して監視
      _catSub = userCollection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) async {
        var list = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
        list = await applyCategoryOrder(list);
        setState(() {
          _categories = list;
          _categoriesLoaded = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面描画。カテゴリが読み込まれるまではローディングを表示
    if (!_categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリがまだ存在しない場合は追加を促す画面を表示
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // カテゴリ追加画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryPage()),
              );
            },
            child: Text(AppLocalizations.of(context)!.addCategory),
          ),
        ),
      );
    }

    // 買い物予報を生成するストラテジーを作成
    if (_conditionSettings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final strategy = createStrategy(_conditionSettings!);
    final repo = InventoryRepositoryImpl();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.buyListTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add') {
                // 商品追加画面を開く
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddInventoryPage(categories: _categories),
                  ),
                );
              } else if (value == 'price') {
                // セール情報管理画面を開く
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PriceListPage()),
                );
              } else if (value == 'inventory') {
                // 在庫一覧画面を開く
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => InventoryPage(categories: _categories)),
                );
              } else if (value == 'settings') {
                // 設定画面を開く
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SettingsPage(
                            categories: _categories,
                            onChanged: _updateCategories,
                            onLocaleChanged: (l) =>
                                // ルートの MyAppState に通知してアプリ全体の言語を更新
                                context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                            onConditionChanged: _loadCondition,
                          )),
                );
              }
            },
            // メニューに表示する項目を定義
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'add',
                  child: Text(AppLocalizations.of(context)!.addItem,
                      style: const TextStyle(fontSize: 18))),
              PopupMenuItem(
                  value: 'price',
                  child: Text(AppLocalizations.of(context)!.priceManagement,
                      style: const TextStyle(fontSize: 18))),
              PopupMenuItem(
                  value: 'inventory',
                  child: Text(AppLocalizations.of(context)!.inventoryList,
                      style: const TextStyle(fontSize: 18))),
              PopupMenuItem(
                  value: 'settings',
                  child: Text(AppLocalizations.of(context)!.settings,
                      style: const TextStyle(fontSize: 18))),
            ],
          )
        ],
      ),
      body: StreamBuilder<List<Inventory>>(
        stream: strategy.watch(repo),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final err = snapshot.error?.toString() ?? 'unknown';
            return Center(child: Text(AppLocalizations.of(context)!.loadError(err)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noBuyItems));
          }
          final map = {for (final c in _categories) c.name: <Inventory>[]};
          for (final inv in list) {
            map[inv.category]?.add(inv);
          }
          return DefaultTabController(
            length: _categories.length,
            child: Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  child: TabBar(
                    isScrollable: true,
                    tabs: [
                      for (final c in _categories)
                        Tab(text: map[c.name]!.isNotEmpty ? '${c.name}❗' : c.name),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final c in _categories)
                        map[c.name]!.isEmpty
                            ? Center(child: Text(AppLocalizations.of(context)!.noBuyItems))
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  for (final inv in map[c.name]!)
                                    InventoryCard(
                                      inventory: inv,
                                      buyOnly: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => InventoryDetailPage(
                                              inventoryId: inv.id,
                                              categories: _categories,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
