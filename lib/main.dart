import 'dart:async';
import 'package:flutter/material.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'settings_page.dart';
import 'inventory_detail_page.dart';
import 'stocktake_page.dart';
import 'edit_inventory_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/history_entry.dart';
import 'domain/entities/category.dart';
import 'domain/services/purchase_prediction_strategy.dart';
import 'domain/usecases/watch_inventories.dart';
import 'domain/usecases/update_quantity.dart';
import 'domain/usecases/delete_inventory.dart';

// アプリのエントリーポイント。Firebase を初期化してから起動する。

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase の初期設定
  runApp(const MyApp()); // アプリのスタート
}

// アプリのルートウィジェット
class MyApp extends StatelessWidget {
  final List<Category>? initialCategories;
  const MyApp({super.key, this.initialCategories});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'おうちストック',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomePage(categories: initialCategories),
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
        appBar: AppBar(title: const Text('おうちストック')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('おうちストック')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryPage()),
              );
            },
            child: const Text('カテゴリを追加'),
          ),
        ),
      );
    }
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('おうちストック'),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddInventoryPage(categories: _categories),
                    ),
                  );
                } else if (value == 'stock') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const StocktakePage()),
                  );
                } else if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => SettingsPage(
                              categories: _categories,
                              onChanged: _updateCategories,
                            )),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'add',
                    child: Text('商品を追加', style: TextStyle(fontSize: 18))),
                const PopupMenuItem(
                    value: 'stock',
                    child: Text('棚卸入力', style: TextStyle(fontSize: 18))),
                const PopupMenuItem(
                    value: 'settings',
                    child: Text('設定', style: TextStyle(fontSize: 18))),
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
          final err = snapshot.error?.toString() ?? '不明なエラー';
          return Center(child: Text('読み込みエラー: $err'));
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
                          title: const Text('編集'),
                          onTap: () => Navigator.pop(context, 'edit'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('削除'),
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
                        const SnackBar(content: Text('削除に失敗しました')),
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

// 1件分の在庫情報を表示するカードウィジェット
class InventoryCard extends StatelessWidget {
  final Inventory inventory;
  final UpdateQuantity _update = UpdateQuantity(InventoryRepositoryImpl());
  final InventoryRepositoryImpl _repository = InventoryRepositoryImpl();

  InventoryCard({
    super.key,
    required this.inventory,
  });

  /// 履歴を読み込み購入予測日を計算する。
  Future<DateTime> _loadPrediction() async {
    final list = await _repository.watchHistory(inventory.id).first;
    final strategy = const DummyPredictionStrategy();
    final predicted = strategy.predict(
        DateTime.now(), list, _currentQuantity(list));
    return predicted;
  }

  double _currentQuantity(List<HistoryEntry> history) {
    if (history.isEmpty) return 0;
    double total = 0;
    for (final h in history.reversed) {
      if (h.type == 'stocktake') {
        total = h.after;
      } else if (h.type == 'add' || h.type == 'bought') {
        total += h.quantity;
      } else if (h.type == 'used') {
        total -= h.quantity;
      }
    }
    return total;
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }

  Future<double?> _inputAmountDialog(
    BuildContext context,
    String title,
  ) async {
    final controller = TextEditingController(text: '1.0');
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text);
                Navigator.pop(context, v);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    double amount,
    String type,
  ) async {
    try {
      await _update(inventory.id, amount, type);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新に失敗しました')),
      );
    }
  }

  Future<void> onUsed(BuildContext context) async {
    final v = await _inputAmountDialog(context, '使った量');
    if (v == null) return;
    await _updateQuantity(context, -v, 'used');
  }

  Future<void> onBought(BuildContext context) async {
    final v = await _inputAmountDialog(context, '買った量');
    if (v == null) return;
    await _updateQuantity(context, v, 'bought');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DateTime>(
      future: _loadPrediction(),
      builder: (context, snapshot) {
        final predicted = snapshot.data;
        final dateText =
            predicted != null ? _formatDate(predicted) : '計算中...';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${inventory.itemType} / ${inventory.itemName}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      '${inventory.quantity.toStringAsFixed(1)}${inventory.unit}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Text(
                      '予測: $dateText',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onUsed(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onBought(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
