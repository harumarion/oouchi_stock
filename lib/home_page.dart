import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_category_page.dart';
import "domain/entities/category.dart";
import "domain/entities/buy_item.dart";
import 'widgets/settings_menu_button.dart';
import 'widgets/prediction_card.dart';
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.noCategories),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCategory),
              ),
            ],
          ),
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
            body: Center(child: Text(AppLocalizations.of(context)!.noBuyItems)),
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
            body: TabBarView(
              children: [
                for (final c in _viewModel.categories)
                  map[c.name]!.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noBuyItems))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final item in map[c.name]!)
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
        );
      },
    );
  }
}
