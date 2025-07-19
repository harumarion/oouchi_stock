import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_category_page.dart';
import 'add_inventory_page.dart';
import 'inventory_detail_page.dart';
import 'widgets/inventory_card.dart';
import 'widgets/settings_menu_button.dart';
import 'widgets/search_sort_row.dart';
import 'widgets/empty_state.dart';
import 'main.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'presentation/viewmodels/inventory_page_viewmodel.dart';
import 'presentation/viewmodels/inventory_list_viewmodel.dart';

/// 在庫一覧画面。カテゴリごとに SegmentedButton で切り替える。
class InventoryPage extends StatefulWidget {
  /// 起動時に受け取るカテゴリ一覧。null の場合は Firestore から取得する
  final List<Category>? categories;
  const InventoryPage({super.key, this.categories});

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

/// InventoryPage の状態クラス。タブ表示やリスト更新を制御する
class InventoryPageState extends State<InventoryPage> {
  /// 画面全体の状態を管理する ViewModel
  late final InventoryPageViewModel _viewModel;
  int _index = 0; // SegmentedButton で選択中のカテゴリインデックス

  /// 画面が再表示された際にカテゴリを最新化する
  Future<void> refresh() async {
    await _viewModel.refresh();
  }

  @override
  void initState() {
    super.initState();
    _viewModel = InventoryPageViewModel();
    _viewModel.addListener(() {
      // カテゴリ削除時にインデックスが範囲外にならないよう調整
      if (_index >= _viewModel.categories.length) {
        _index = 0;
      }
      if (mounted) setState(() {});
    });
    _viewModel.loadCategories(widget.categories);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面描画。カテゴリが読み込まれるまではローディングを表示
    if (!_viewModel.categoriesLoaded) {
      return Scaffold(
        // 画面名を在庫一覧に固定
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryList)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリがまだ存在しない場合は案内テキストと追加ボタンを表示
    if (_viewModel.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryList)),
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
    return Scaffold(
          appBar: AppBar(
            // 上部タイトルを在庫一覧にする
            // 他画面と同様に左寄せ表示にするため centerTitle を false に設定
            title: Text(AppLocalizations.of(context)!.inventoryList),
            centerTitle: false,
            actions: [
              // 設定のみを表示する統一メニュー
              SettingsMenuButton(
                categories: _viewModel.categories,
                onCategoriesChanged: _viewModel.updateCategories,
                onLocaleChanged: (l) =>
                    context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                onConditionChanged: () {},
              )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (var i = 0; i < _viewModel.categories.length; i++)
                      ButtonSegment<int>(
                        value: i,
                        label: Text(_viewModel.categories[i].name),
                      )
                  ],
                  selected: {_index},
                  onSelectionChanged: (s) => setState(() => _index = s.first),
                ),
              ),
              Expanded(
                child: InventoryList(
                  // カテゴリ変更時に状態をリセットするためキーを指定
                  key: ValueKey(_viewModel.categories[_index].id),
                  category: _viewModel.categories[_index].name,
                  categories: _viewModel.categories,
                ),
              ),
            ],
          ),
          // 画面右下のプラスボタンを押すと商品追加画面を開く
          floatingActionButton: FloatingActionButton(
            // 在庫一覧画面専用のヒーロータグ
            heroTag: 'inventoryFab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddInventoryPage(categories: _viewModel.categories),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
  }
}

/// 指定カテゴリの在庫を一覧表示するウィジェット。
/// 検索バーを SliverAppBar として表示する。
class InventoryList extends StatefulWidget {
  final String category;
  final List<Category> categories;
  const InventoryList({super.key, required this.category, required this.categories});

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  /// リスト表示を制御する ViewModel
  late final InventoryListViewModel _viewModel;
  /// Dismissible のアニメーション中に一時保持する削除済み在庫ID
  final Set<String> _removedIds = {};

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _viewModel = InventoryListViewModel(category: widget.category)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant InventoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // カテゴリが変更されたときは ViewModel を再生成してストリームを更新
    if (oldWidget.category != widget.category) {
      _viewModel.dispose();
      _viewModel = InventoryListViewModel(category: widget.category)
        ..addListener(() {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          title: SearchSortRow(
            controller: _viewModel.controller,
            onSearchChanged: _viewModel.setSearch,
            sortValue: _viewModel.sort,
            onSortChanged: (v) {
              if (v != null) _viewModel.setSort(v);
            },
            items: [
              DropdownMenuItem(
                value: 'alphabet',
                child: Text(AppLocalizations.of(context)!.sortAlphabet),
              ),
              DropdownMenuItem(
                value: 'updated',
                child: Text(AppLocalizations.of(context)!.sortUpdated),
              ),
            ],
          ),
        ),
        StreamBuilder<List<Inventory>>(
          stream: _viewModel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              final err = snapshot.error?.toString() ?? 'unknown';
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(AppLocalizations.of(context)!.loadError(err)),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            var list = snapshot.data!
                .where((inv) =>
                    inv.itemName.contains(_viewModel.search) ||
                    inv.category.contains(_viewModel.search) ||
                    inv.itemType.contains(_viewModel.search))
                .toList();
            _removedIds.removeWhere((id) => list.every((e) => e.id != id));
            list = list.where((e) => !_removedIds.contains(e.id)).toList();
            if (_viewModel.sort == 'alphabet') {
              list.sort((a, b) => a.itemName.compareTo(b.itemName));
            } else {
              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final inv = list[index];
                    return Dismissible(
                      key: ValueKey(inv.id),
                      direction: DismissDirection.startToEnd,
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
                      onDismissed: (_) async {
                        setState(() {
                          _removedIds.add(inv.id);
                        });
                        try {
                          await _viewModel.delete(inv.id);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(AppLocalizations.of(context)!.deleteFailed),
                              ),
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
                      child: InventoryCard(
                        inventory: inv,
                        updateQuantity: _viewModel.updateQuantity,
                        stocktake: _viewModel.stocktake,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InventoryDetailPage(
                                inventoryId: inv.id,
                                categories: widget.categories,
                              ),
                            ),
                          );
                        },
                        onAddToList: () async {
                          await _viewModel.addToBuyList(inv);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    AppLocalizations.of(context)!.addedBuyItem),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
