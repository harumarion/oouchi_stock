import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'settings_page.dart';
import 'inventory_detail_page.dart';
import 'edit_inventory_page.dart';
import 'price_list_page.dart';
import 'buy_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/history_entry.dart';
import 'domain/entities/category.dart';
import 'domain/services/purchase_prediction_strategy.dart';
import 'domain/usecases/watch_inventories.dart';
import 'domain/usecases/update_quantity.dart';
import 'domain/usecases/delete_inventory.dart';
import 'domain/usecases/stocktake.dart';
import 'notification_service.dart';

// アプリのエントリーポイント。Firebase を初期化してから起動する。

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase の初期設定
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final loc = await AppLocalizations.delegate.load(locale);
  final notification = NotificationService();
  await notification.init();
  await notification.scheduleWeekly(
    id: 0,
    title: loc.buyListNotificationTitle,
    body: loc.buyListNotificationBody,
  );
  runApp(const MyApp()); // アプリのスタート
}

// アプリのルートウィジェット
class MyApp extends StatefulWidget {
  final List<Category>? initialCategories;
  const MyApp({super.key, this.initialCategories});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) setState(() => _locale = Locale(code));
  }

  Future<void> _updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomePage(categories: widget.initialCategories),
    );
  }
}

// 在庫一覧を表示する画面
class HomePage extends StatefulWidget {
  final List<Category>? categories;
  const HomePage({super.key, this.categories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  bool _categoriesLoaded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;

// カテゴリ設定画面で編集後にリストを更新する
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
    if (!_categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
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
                      builder: (_) =>
                          AddInventoryPage(categories: _categories),
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
                                  context.findAncestorStateOfType<_MyAppState>()?._updateLocale(l),
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
    final watchUsecase = WatchInventories(InventoryRepositoryImpl());
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
                );
                if (result == 'delete') {
                  try {
                    await deleteUsecase(inv.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.deleteFailed)),
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
                              id: 0,
                              name: inv.category,
                              createdAt: DateTime.now()),
                        ),
                        itemType: inv.itemType,
                        unit: inv.unit,
                        note: inv.note,
                      ),
                    ),
                  );
                }
              },
              child: InventoryCard(inventory: inv),
            );
          }).toList(),
        );
      },
    );
  }
}

