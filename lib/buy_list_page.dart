import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'data/repositories/buy_list_repository_impl.dart';
import 'domain/entities/buy_item.dart';
import 'domain/usecases/add_buy_item.dart';
import 'domain/usecases/remove_buy_item.dart';
import 'domain/usecases/watch_buy_items.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'domain/services/buy_list_strategy.dart';
import 'inventory_detail_page.dart';
import 'widgets/inventory_card.dart';
import 'domain/entities/category_order.dart';
import 'widgets/settings_menu_button.dart';

/// 買い物予報画面
/// ホーム画面のメニューから遷移し、今買っておいた方が良い商品を表示する
class BuyListPage extends StatefulWidget {
  final List<Category>? categories;
  const BuyListPage({super.key, this.categories});

  @override
  State<BuyListPage> createState() => _BuyListPageState();
}

class _BuyListPageState extends State<BuyListPage> {
  List<Category> _categories = [];
  bool _loaded = false;
  BuyListConditionSettings? _condition;
  final BuyListRepositoryImpl _buyRepo = BuyListRepositoryImpl();
  late final AddBuyItem _addUsecase = AddBuyItem(_buyRepo);
  late final RemoveBuyItem _removeUsecase = RemoveBuyItem(_buyRepo);
  late final WatchBuyItems _watchUsecase = WatchBuyItems(_buyRepo);
  late final TextEditingController _itemController;
  // 在庫一覧のストリームを購読し、買い物予報に反映する
  StreamSubscription<List<Inventory>>? _invSub;

  /// 設定画面から戻った際に呼び出され、カテゴリリストを更新する
  void _updateCategories(List<Category> list) {
    setState(() => _categories = List.from(list));
  }

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController();
    _load();
  }

  // BuyListPage 起動時に呼び出し、カテゴリ一覧と条件設定を読み込む
  Future<void> _load() async {
    if (widget.categories != null) {
      // 設定画面から受け取ったカテゴリを並び順付きで保持
      _categories = List.from(widget.categories!);
      _categories = await applyCategoryOrder(_categories);
    } else {
      final snapshot = await userCollection('categories')
          .orderBy('createdAt')
          .get();
      _categories = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
      // Firestore 取得時にも並び順を適用する
      _categories = await applyCategoryOrder(_categories);
    }
    _condition = await loadBuyListConditionSettings();
    setState(() => _loaded = true);
    final strategy = createStrategy(_condition!);
    final repo = InventoryRepositoryImpl();
    // 条件に合致した在庫が通知された際に買い物リストへ追加する
    _invSub = strategy.watch(repo).listen((list) {
      for (final inv in list) {
        _addUsecase(BuyItem(inv.itemName, inv.category, inv.id));
      }
    });
  }

  @override
  void dispose() {
    _invSub?.cancel();
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _condition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return StreamBuilder<List<BuyItem>>(
      stream: _watchUsecase(),
      builder: (context, snapshot) {
        final loc = AppLocalizations.of(context)!;
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final list = snapshot.data!;
        final map = {for (final c in _categories) c.name: <BuyItem>[]};
        final manual = <BuyItem>[];
        for (final item in list) {
          if (map.containsKey(item.category)) {
            map[item.category]!.add(item);
          } else {
            manual.add(item);
          }
        }
        final tabs = ['手動', ..._categories.map((e) => e.name)];
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(loc.buyList),
              // 設定画面を開くメニューボタンを追加
              actions: [
                SettingsMenuButton(
                  categories: _categories,
                  onCategoriesChanged: _updateCategories,
                  onLocaleChanged: (l) => context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                  onConditionChanged: _load,
                )
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (final t in tabs)
                    // 最大3件まで画面幅いっぱいに表示し、それ以上はスクロール
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Tab(text: t),
                    )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _manualTab(manual, loc),
                for (final c in _categories)
                  _categoryTab(map[c.name]!, loc),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _categoryTab(List<BuyItem> items, AppLocalizations loc) {
    if (items.isEmpty) {
      return Center(child: Text(loc.noBuyItems));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final item in items)
          _dismissibleCard(item, loc),
      ],
    );
  }

  Widget _manualTab(List<BuyItem> items, AppLocalizations loc) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: InputDecoration(labelText: loc.enterItemName),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final text = _itemController.text.trim();
                  if (text.isEmpty) return;
                  await _addUsecase(BuyItem(text, ''));
                  _itemController.clear();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.addedBuyItem)),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(child: _categoryTab(items, loc)),
      ],
    );
  }

  Widget _dismissibleCard(BuyItem item, AppLocalizations loc) {
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                content: Text(loc.confirmDelete),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(loc.cancel)),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(loc.delete)),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => _removeUsecase(item),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(item.name),
          trailing: item.inventoryId == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryDetailPage(
                          inventoryId: item.inventoryId!,
                          categories: _categories,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
