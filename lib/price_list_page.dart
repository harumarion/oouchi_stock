import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_price_page.dart';
import 'add_category_page.dart';
import 'widgets/settings_menu_button.dart';
import 'presentation/viewmodels/price_list_viewmodel.dart';
import 'presentation/viewmodels/price_category_list_viewmodel.dart';
import 'price_detail_page.dart';
import 'main.dart';
import 'widgets/scrolling_text.dart';
import 'domain/entities/price_info.dart';

/// セール情報管理画面
class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends State<PriceListPage> {
  late final PriceListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PriceListViewModel();
    _viewModel.addListener(() { if (mounted) setState(() {}); });
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceManagementTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_viewModel.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceManagementTitle)),
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
    return DefaultTabController(
      length: _viewModel.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.priceManagementTitle),
          actions: [
            SettingsMenuButton(
              categories: _viewModel.categories,
              onCategoriesChanged: (l) {},
              onLocaleChanged: (l) => context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
              onConditionChanged: () {},
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
            for (final c in _viewModel.categories) PriceCategoryList(category: c.name)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'priceListFab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPricePage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// カテゴリ別セール一覧ウィジェット
class PriceCategoryList extends StatefulWidget {
  /// 表示対象のカテゴリ名
  final String category;

  /// テスト用に注入する ViewModel (通常は null)
  final PriceCategoryListViewModel? viewModel;

  const PriceCategoryList({super.key, required this.category, this.viewModel});

  @override
  State<PriceCategoryList> createState() => _PriceCategoryListState();
}

class _PriceCategoryListState extends State<PriceCategoryList> {
  /// カテゴリリストを管理する ViewModel
  late final PriceCategoryListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ??
        PriceCategoryListViewModel(category: widget.category);
    _viewModel.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _viewModel.controller,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchHint,
                  ),
                  onChanged: _viewModel.setSearch,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _viewModel.sort,
                onChanged: (v) { if (v != null) _viewModel.setSort(v); },
                items: [
                  DropdownMenuItem(
                    value: 'alphabet',
                    child: Text(AppLocalizations.of(context)!.sortAlphabet),
                  ),
                  DropdownMenuItem(
                    value: 'updated',
                    child: Text(AppLocalizations.of(context)!.sortUpdated),
                  ),
                  DropdownMenuItem(
                    value: 'unitPrice',
                    child: Text(AppLocalizations.of(context)!.sortUnitPrice),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.showExpired),
                  Switch(
                    value: _viewModel.showExpired,
                    onChanged: _viewModel.setShowExpired,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<PriceInfo>>(
            stream: _viewModel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                final err = snapshot.error?.toString() ?? 'unknown';
                return Center(child: Text(AppLocalizations.of(context)!.loadError(err)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var items = snapshot.data!
                  .where((e) => e.itemName.contains(_viewModel.search) ||
                      e.category.contains(_viewModel.search) ||
                      e.itemType.contains(_viewModel.search))
                  .where((e) => _viewModel.showExpired || e.expiry.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                  .toList();
              if (_viewModel.sort == 'alphabet') {
                items.sort((a, b) => a.itemType.compareTo(b.itemType));
              } else if (_viewModel.sort == 'unitPrice') {
                items.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
              } else {
                items.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];
                  final diff = p.regularPrice - p.salePrice;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ScrollingText(
                                  '${p.itemType} / ${p.itemName}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PriceDetailPage(info: p)),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.deleteConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text(AppLocalizations.of(context)!.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text(AppLocalizations.of(context)!.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await _viewModel.delete(p.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(AppLocalizations.of(context)!.deleted)),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.expiry(_formatDate(p.expiry))),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.regularPriceLabel(p.regularPrice.toStringAsFixed(0))),
                          Text(AppLocalizations.of(context)!.salePriceLabel(p.salePrice.toStringAsFixed(0))),
                          Text(AppLocalizations.of(context)!.priceDiffLabel(diff.toStringAsFixed(0))),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }
}
