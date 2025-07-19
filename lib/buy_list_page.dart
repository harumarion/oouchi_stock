import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'presentation/viewmodels/buy_list_viewmodel.dart';
import 'domain/entities/buy_item.dart';
import 'domain/entities/category.dart';
import 'widgets/settings_menu_button.dart';
import 'widgets/buy_list_card.dart';
import 'widgets/empty_state.dart';
// 言語変更時にアプリ全体のロケールを更新するため MyAppState を参照
import 'main.dart';

/// 買い物予報画面
/// ホーム画面のメニューから遷移し、今買っておいた方が良い商品を表示する
class BuyListPage extends StatefulWidget {
  /// 外部から渡されるカテゴリ一覧
  final List<Category>? categories;
  /// テスト用に ViewModel を差し替え可能
  final BuyListViewModel? viewModel;

  BuyListPage({
    super.key,
    this.categories,
    this.viewModel,
  });

  @override
  State<BuyListPage> createState() => BuyListPageState();
}

/// BuyListPage の状態クラス。画面表示時や更新時の処理を行う
class BuyListPageState extends State<BuyListPage> {
  /// 画面状態を管理する ViewModel
  late final BuyListViewModel _viewModel;
  /// 検索バー制御用コントローラ
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? BuyListViewModel();
    _searchController = SearchController();
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
    _searchController.dispose();
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
                child: SearchAnchor.bar(
                  searchController: _searchController,
                  barHintText: loc.enterItemName,
                  suggestionsBuilder: (context, controller) {
                    final query = controller.text;
                    final list = _viewModel.suggestions
                        .where((e) => e.contains(query))
                        .toList();
                    return list
                        .map((s) => ListTile(
                              title: Text(s),
                              onTap: () {
                                controller.closeView(s);
                                _searchController.text = s;
                              },
                            ))
                        .toList();
                  },
                  trailing: [
                    IconButton(
                      onPressed: () async {
                        _viewModel.itemController.text = _searchController.text;
                        await _viewModel.addManualItem();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.addedBuyItem)),
                        );
                      },
                      icon: const Icon(Icons.add),
                    )
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? EmptyState(message: loc.noBuyItems)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final item in list)
                            // 買い物カードをリスト表示
                            BuyListCard(
                              item: item,
                              categories: _viewModel.categories,
                              watchInventory: _viewModel.watchInventory,
                              calcDaysLeft: _viewModel.calcDaysLeft,
                              updateQuantity: _viewModel.updateQuantity,
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
