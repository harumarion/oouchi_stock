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
import 'presentation/viewmodels/buy_list_viewmodel.dart';

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
  /// 画面状態を管理する ViewModel
  late final BuyListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final buyRepo = BuyListRepositoryImpl();
    _viewModel = BuyListViewModel(
      repository: widget.repository,
      addUsecase: AddBuyItem(buyRepo),
      removeUsecase: RemoveBuyItem(buyRepo),
      watchUsecase: WatchBuyItems(buyRepo),
    );
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.load(initialCategories: widget.categories);
  }

  /// 画面が再表示されたときに最新情報を取得する
  Future<void> refresh() async {
    await _viewModel.refresh();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.loaded || _viewModel.condition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return StreamBuilder<List<BuyItem>>(
      stream: _viewModel.stream,
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
                categories: _viewModel.categories,
                onCategoriesChanged: _viewModel.updateCategories,
                onLocaleChanged: (l) =>
                    context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                onConditionChanged: _viewModel.refresh,
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
                        controller: _viewModel.itemController,
                        decoration: InputDecoration(labelText: loc.enterItemName),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _viewModel.addManualItem();
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
                              categories: _viewModel.categories,
                              repository: widget.repository,
                              onRemove: _viewModel.removeItem,
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
