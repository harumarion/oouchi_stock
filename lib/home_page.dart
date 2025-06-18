import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'price_list_page.dart';
import 'inventory_page.dart';
import 'settings_page.dart';
import 'main.dart'; // アプリ全体の状態を取得するため
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/usecases/watch_low_inventory.dart';

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

  /// 設定画面から戻った際にカテゴリリストを更新する
  void _updateCategories(List<Category> list) {
    setState(() {
      _categories = List.from(list);
      _categoriesLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.categories != null) {
      _categories = List.from(widget.categories!);
      _categoriesLoaded = true;
    } else {
      // Firestore からカテゴリ一覧を取得して監視
      _catSub = FirebaseFirestore.instance
          .collection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _categories = snapshot.docs.map((d) {
            final data = d.data();
            return Category(
              id: data['id'] ?? 0,
              name: data['name'] ?? '',
              createdAt: (data['createdAt'] as Timestamp).toDate(),
            );
          }).toList();
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

    // 残量がしきい値以下の在庫を監視するユースケース
    final watch = WatchLowInventory(InventoryRepositoryImpl());
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
                // 値段管理画面を開く
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
                            // 設定画面で言語変更後、アプリのロケールを更新
                            onLocaleChanged: (l) =>
                                context.findAncestorStateOfType<MyAppState>()?._updateLocale(l),
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
        stream: watch(0),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final inv in list)
                ListTile(
                  title: Text('${inv.itemType} / ${inv.itemName}'),
                  subtitle: Text('${inv.quantity.toStringAsFixed(1)}${inv.unit}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
