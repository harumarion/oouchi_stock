import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_category_page.dart';
import "domain/entities/category.dart";
import "domain/entities/buy_item.dart";
import 'widgets/settings_menu_button.dart';
import 'widgets/prediction_card.dart';
import 'widgets/empty_state.dart';
import 'main.dart';
import 'presentation/viewmodels/home_page_viewmodel.dart';

/// ホーム画面。起動時に表示され、買い物リストを管理する。
class HomePage extends StatefulWidget {
  final List<Category>? categories;
  const HomePage({super.key, this.categories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomePageViewModel();
    _viewModel.addListener(() { if (mounted) setState(() {}); });
    _viewModel.loadCondition();
    _viewModel.loadCategories(widget.categories);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_viewModel.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: EmptyState(
          message: AppLocalizations.of(context)!.noCategories,
          buttonLabel: AppLocalizations.of(context)!.addCategory,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryPage()),
            );
          },
        ),
      );
    }
    if (_viewModel.conditionSettings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return StreamBuilder<List<BuyItem>>(
      stream: _viewModel.watchPrediction(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
            body: EmptyState(message: AppLocalizations.of(context)!.noBuyItems),
          );
        }
        final map = {for (final c in _viewModel.categories) c.name: <BuyItem>[]};
        for (final item in items) {
          map[item.category]?.add(item);
        }
        return DefaultTabController(
          length: _viewModel.categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.buyListTitle),
              actions: [
                SettingsMenuButton(
                  categories: _viewModel.categories,
                  onCategoriesChanged: _viewModel.updateCategories,
                  onLocaleChanged: (l) => context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                  onConditionChanged: _viewModel.loadCondition,
                )
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (final c in _viewModel.categories)
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Tab(text: c.name),
                    )
                ],
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  // 買い物予報検索用 SearchAnchor
                  child: SearchAnchor.bar(
                    searchController: _viewModel.controller,
                    barHintText: AppLocalizations.of(context)!.searchHint,
                    suggestionsBuilder: (context, controller) => const [],
                    barLeading: const Icon(Icons.search),
                    onChanged: _viewModel.setSearch,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final c in _viewModel.categories)
                        map[c.name]!
                                .where((e) =>
                                    e.name.contains(_viewModel.search) ||
                                    e.category.contains(_viewModel.search))
                                .isEmpty
                            ? EmptyState(message: AppLocalizations.of(context)!.noBuyItems)
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  for (final item in map[c.name]!
                                      .where((e) =>
                                          e.name.contains(_viewModel.search) ||
                                          e.category.contains(_viewModel.search)))
                                    PredictionCard(
                                      item: item,
                                      categories: _viewModel.categories,
                                      watchInventory: _viewModel.watchInventory,
                                      addToBuyList: _viewModel.addPredictionToBuyList,
                                      removePrediction: _viewModel.removePredictionItem,
                                      calcDaysLeft: _viewModel.calcDaysLeft,
                                    ),
                                ],
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
