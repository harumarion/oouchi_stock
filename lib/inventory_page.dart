import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'buy_list_page.dart';
import 'price_list_page.dart';
import 'settings_page.dart';
import 'inventory_detail_page.dart';
import 'edit_inventory_page.dart';
import 'widgets/inventory_card.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/usecases/watch_inventories.dart';
import 'domain/usecases/delete_inventory.dart';

/// 在庫一覧画面。カテゴリごとの在庫をタブ形式で表示する。
class InventoryPage extends StatefulWidget {
  /// 起動時に受け取るカテゴリ一覧。null の場合は Firestore から取得する
  final List<Category>? categories;
  const InventoryPage({super.key, this.categories});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリがまだ存在しない場合は追加を促す画面を表示
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
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
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle),
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                for (final c in _categories)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Tab(text: c.name),
                  )
              ],
            ),
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
                  } else if (value == 'buylist') {
                    // 買い物リスト画面を開く
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyListPage()),
                    );
                  } else if (value == 'settings') {
                    // 設定画面を開く
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => SettingsPage(
                                categories: _categories,
                                onChanged: _updateCategories,
                                onLocaleChanged: (l) =>
                                    context.findAncestorStateOfType<MyAppState>()?._updateLocale(l),
                              )),
                    );
                  }
                },
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
                      value: 'buylist',
                      child: Text(AppLocalizations.of(context)!.buyList,
                          style: const TextStyle(fontSize: 18))),
                  PopupMenuItem(
                      value: 'settings',
                      child: Text(AppLocalizations.of(context)!.settings,
                          style: const TextStyle(fontSize: 18))),
                ],
              )
            ],
          ),
          body: TabBarView(
            children: [
              for (final c in _categories)
                InventoryList(category: c.name, categories: _categories)
            ],
          ),
          // 在庫一覧から商品を追加する機能はメニューからのみ利用するため
          // ここで表示していた追加用の FAB は削除する。
        ),
    );
  }
}

/// 指定カテゴリの在庫を一覧表示するウィジェット。
class InventoryList extends StatelessWidget {
  final String category;
  final List<Category> categories;
  const InventoryList({super.key, required this.category, required this.categories});

  @override
  Widget build(BuildContext context) {
    // 指定カテゴリの在庫一覧をストリームで監視して表示
    final watchUsecase = WatchInventories(InventoryRepositoryImpl());
    // 削除処理を行うユースケース
    final deleteUsecase = DeleteInventory(InventoryRepositoryImpl());
    return StreamBuilder<List<Inventory>>(
      stream: watchUsecase(category),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error?.toString() ?? 'unknown';
          return Center(
            child: Text(AppLocalizations.of(context)!.loadError(err)),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: list.map((inv) {
            return GestureDetector(
              onTap: () {
                // 在庫カードをタップすると詳細画面へ
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryDetailPage(
                      inventoryId: inv.id,
                      categories: categories,
                    ),
                  ),
                );
              },
              onLongPress: () async {
                // 長押しで編集・削除メニューを表示
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => SafeArea(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppLocalizations.of(context)!.categoryEditTitle),
                          onTap: () => Navigator.pop(context, 'edit'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context)!.delete),
                          onTap: () => Navigator.pop(context, 'delete'),
                        ),
                      ],
                    ),
                  ),
                ); // 選択結果が 'edit' または 'delete' で返る
                if (result == 'delete') {
                  try {
                    await deleteUsecase(inv.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
                      );
                    }
                  }
                } else if (result == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditInventoryPage(
                        id: inv.id,
                        itemName: inv.itemName,
                        category: categories.firstWhere(
                          (e) => e.name == inv.category,
                          orElse: () => Category(
                              id: 0, name: inv.category, createdAt: DateTime.now()),
                        ),
                        itemType: inv.itemType,
                        unit: inv.unit,
                        note: inv.note,
                      ),
                    ),
                  );
                }
              },
              // 各在庫を表示するカードウィジェット
              child: InventoryCard(inventory: inv),
            );
          }).toList(),
        );
      },
    );
  }
}
