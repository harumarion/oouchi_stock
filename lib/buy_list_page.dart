import 'dart:async';
import 'package:flutter/material.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'data/repositories/buy_list_repository_impl.dart';
import 'domain/entities/buy_item.dart';
import 'domain/usecases/add_buy_item.dart';
import 'domain/usecases/remove_buy_item.dart';
import 'domain/usecases/watch_buy_items.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'domain/services/buy_list_strategy.dart';
import 'domain/entities/category_order.dart';
import 'widgets/settings_menu_button.dart';
import 'widgets/buy_list_card.dart';
// 言語変更時にアプリ全体のロケールを更新するため MyAppState を参照
import 'main.dart';

/// 買い物予報画面
/// ホーム画面のメニューから遷移し、今買っておいた方が良い商品を表示する
class BuyListPage extends StatefulWidget {
  /// 外部から渡されるカテゴリ一覧
  final List<Category>? categories;
  /// 在庫データ取得用リポジトリ
  final InventoryRepository repository;

  BuyListPage({
    super.key,
    this.categories,
    InventoryRepository? repository,
  }) : repository = repository ?? InventoryRepositoryImpl();

  @override
  State<BuyListPage> createState() => BuyListPageState();
}

/// BuyListPage の状態クラス。画面表示時や更新時の処理を行う
class BuyListPageState extends State<BuyListPage> {
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
    // 既存の購読がある場合は一度キャンセルする
    await _invSub?.cancel();
    // カテゴリが渡されており、件数が 1 件以上の場合のみそのまま使用
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      // 設定画面から受け取ったカテゴリを並び順付きで保持
      _categories = List.from(widget.categories!);
      _categories = await applyCategoryOrder(_categories);
    } else {
      // カテゴリが空の場合は Firestore から取得
      final snapshot = await userCollection('categories')
          .orderBy('createdAt')
          .get();
      _categories = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: parseDateTime(data['createdAt']),
          color: data['color'],
        );
      }).toList();
      // Firestore 取得時にも並び順を適用する
      _categories = await applyCategoryOrder(_categories);
    }
    _condition = await loadBuyListConditionSettings();
    setState(() => _loaded = true);
    final strategy = createStrategy(_condition!);
    // BuyListStrategy で条件に合致した在庫が通知されたらリストへ追加
    _invSub = strategy.watch(widget.repository).listen((list) {
      for (final inv in list) {
        _addUsecase(BuyItem(inv.itemName, inv.category, inv.id));
      }
    });
  }

  /// 画面が再表示されたときに最新情報を取得する
  Future<void> refresh() async {
    await _load();
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
        return Scaffold(
          appBar: AppBar(
            title: Text(loc.buyList),
            actions: [
              SettingsMenuButton(
                categories: _categories,
                onCategoriesChanged: _updateCategories,
                onLocaleChanged: (l) =>
                    context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                onConditionChanged: _load,
              )
            ],
          ),
          body: Column(
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
              Expanded(
                child: list.isEmpty
                    ? Center(child: Text(loc.noBuyItems))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final item in list)
                            // 買い物カードをリスト表示
                            BuyListCard(
                              item: item,
                              categories: _categories,
                              repository: widget.repository,
                              onRemove: _removeUsecase,
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

}
