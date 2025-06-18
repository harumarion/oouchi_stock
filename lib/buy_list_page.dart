import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'domain/services/buy_list_strategy.dart';
import 'inventory_detail_page.dart';
import 'widgets/inventory_card.dart';

/// 買うべきリスト画面
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
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.buyListTitle),
      ),
      // 在庫データのストリームを監視してリストを更新
      body: StreamBuilder<List<Inventory>>( 
        stream: strategy.watch(repo),
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
          if (list.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noBuyItems));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final inv in list)
                // 買うべきリストでは購入のみ可能
                InventoryCard(
                  inventory: inv,
                  buyOnly: true, // 購入ボタンのみ表示
                  // 在庫カードタップで詳細画面へ遷移
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
          );
        },
      ),
    );
  }
}
