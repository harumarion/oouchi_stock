import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'domain/services/buy_list_strategy.dart';
import 'inventory_detail_page.dart';
import 'widgets/inventory_card.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  // 画面起動時に呼び出し、カテゴリ一覧と条件設定を読み込む
  Future<void> _load() async {
    if (widget.categories != null) {
      _categories = List.from(widget.categories!);
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
    }
    _condition = await loadBuyListConditionSettings();
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _condition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final strategy = createStrategy(_condition!);
    final repo = InventoryRepositoryImpl();
    return StreamBuilder<List<Inventory>>(
        stream: strategy.watch(repo),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final err = snapshot.error?.toString() ?? 'unknown';
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
              body: Center(child: Text(AppLocalizations.of(context)!.loadError(err))),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
              body: Center(child: Text(AppLocalizations.of(context)!.noBuyItems)),
            );
          }
          final map = {for (final c in _categories) c.name: <Inventory>[]};
          for (final inv in list) {
            map[inv.category]?.add(inv);
          }
          return DefaultTabController(
            length: _categories.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.buyListTitle),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: [
                    for (final c in _categories)
                      Tab(text: map[c.name]!.isNotEmpty ? '${c.name}❗' : c.name),
                  ],
                ),
              ),
              body: TabBarView(
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
          );
        },
      );
  }
}
