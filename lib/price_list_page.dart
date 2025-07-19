import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_price_page.dart';
import 'add_category_page.dart';
import 'widgets/settings_menu_button.dart';
import 'widgets/empty_state.dart';
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
  /// 画面全体の状態を管理する ViewModel
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
          // セール情報を追加する画面へ遷移
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
  /// Dismissible処理中に保持する削除済みID一覧
  final Set<String> _removedIds = {};

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
          // 検索バーのみ表示し、並び替えや期限表示切替は下部ボトムシートで実施
          child: TextField(
            controller: _viewModel.controller,
            decoration:
                InputDecoration(labelText: AppLocalizations.of(context)!.searchHint),
            onChanged: _viewModel.setSearch,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              StreamBuilder<List<PriceInfo>>(
                stream: _viewModel.stream,
                builder: (context, snapshot) {
              if (snapshot.hasError) {
                final err = snapshot.error?.toString() ?? 'unknown';
                return Center(child: Text(AppLocalizations.of(context)!.loadError(err)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Firestoreから取得した最新データ
              var items = snapshot.data!
                  .where((e) => e.itemName.contains(_viewModel.search) ||
                      e.category.contains(_viewModel.search) ||
                      e.itemType.contains(_viewModel.search))
                  .where((e) => _viewModel.showExpired || e.expiry.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                  .toList();
              // Firestore側で削除完了したIDは一覧から除外
              _removedIds.removeWhere((id) => items.every((e) => e.id != id));
              // スワイプ直後に除外したIDも非表示にする
              items = items.where((e) => !_removedIds.contains(e.id)).toList();
              if (_viewModel.sort == 'alphabet') {
                items.sort((a, b) => a.itemType.compareTo(b.itemType));
              } else if (_viewModel.sort == 'unitPrice') {
                items.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
              } else {
                items.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
              }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                  final p = items[index];
                  // セール価格と通常価格の差額（正負をそのまま表示）
                  final diff = p.salePrice - p.regularPrice;
                  final diffStr = diff > 0
                      ? '+${diff.toStringAsFixed(0)}'
                      : diff.toStringAsFixed(0);
                  return Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.startToEnd,
                    // スワイプ時に削除確認ダイアログを表示
                    confirmDismiss: (_) async {
                      final loc = AppLocalizations.of(context)!;
                      final res = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Text(loc.deleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(loc.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(loc.delete),
                            ),
                          ],
                        ),
                      );
                      return res ?? false;
                    },
                    // 削除処理本体
                    onDismissed: (_) async {
                      setState(() {
                        // Dismissible アニメーション完了後に残らないようIDを記録
                        _removedIds.add(p.id);
                      });
                      try {
                        await _viewModel.delete(p.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.deleted)),
                          );
                        }
                      } catch (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
                          );
                        }
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PriceDetailPage(info: p)),
                          );
                        },
                        leading: IconButton(
                          icon: const Icon(Icons.playlist_add),
                          onPressed: () async {
                            await _viewModel.addToBuyList(p);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.addedBuyItem)),
                              );
                            }
                          },
                        ),
                        title: ScrollingText(
                          '${p.itemName} / ${p.itemType}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(AppLocalizations.of(context)!.expiry(_formatDate(p.expiry))),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.regularPriceLabel(p.regularPrice.toStringAsFixed(0))} '
                              '${AppLocalizations.of(context)!.salePriceLabel(p.salePrice.toStringAsFixed(0))} '
                              '${AppLocalizations.of(context)!.priceDiffLabel(diffStr)}',
                            ),
                            Text(AppLocalizations.of(context)!.unitPrice(p.unitPrice.toStringAsFixed(2))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 並び替えチップと期限表示スイッチを表示するボトムシート
  Widget _buildBottomSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Material(
      elevation: 4,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(loc.sortAlphabet),
                    selected: _viewModel.sort == 'alphabet',
                    onSelected: (_) => _viewModel.setSort('alphabet'),
                  ),
                  ChoiceChip(
                    label: Text(loc.sortUpdated),
                    selected: _viewModel.sort == 'updated',
                    onSelected: (_) => _viewModel.setSort('updated'),
                  ),
                  ChoiceChip(
                    label: Text(loc.sortUnitPrice),
                    selected: _viewModel.sort == 'unitPrice',
                    onSelected: (_) => _viewModel.setSort('unitPrice'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.showExpired),
                  Switch(
                    value: _viewModel.showExpired,
                    onChanged: _viewModel.setShowExpired,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }
}
