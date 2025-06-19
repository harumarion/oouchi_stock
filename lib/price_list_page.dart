import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';

import 'add_price_page.dart';
import 'add_inventory_page.dart';
import 'settings_page.dart';
import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/price_info.dart';
import 'domain/entities/category_order.dart';
import 'domain/usecases/watch_price_by_category.dart';
import 'price_history_page.dart';
import 'main.dart';

class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends State<PriceListPage> {
  List<Category> _categories = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    userCollection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      var list = snapshot.docs.map((d) {
        final data = d.data();
        return Category(
          id: data['id'] ?? 0,
          name: data['name'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
      list = await applyCategoryOrder(list);
      setState(() {
        _categories = list;
        _loaded = true;
      });
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceManagementTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.priceManagementTitle),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddInventoryPage(categories: _categories)),
                  );
                } else if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SettingsPage(
                              categories: _categories,
                              onChanged: (l) {},
                              onLocaleChanged: (l) => context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                              onConditionChanged: () {},
                            )),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'add',
                    child: Text(AppLocalizations.of(context)!.addItem,
                        style: const TextStyle(fontSize: 18))),
                PopupMenuItem(
                    value: 'settings',
                    child: Text(AppLocalizations.of(context)!.settings,
                        style: const TextStyle(fontSize: 18))),
              ],
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final c in _categories) Tab(text: c.name)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in _categories) PriceCategoryList(category: c.name)
          ],
        ),
        floatingActionButton: FloatingActionButton(
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

class PriceCategoryList extends StatefulWidget {
  final String category;
  const PriceCategoryList({super.key, required this.category});

  @override
  State<PriceCategoryList> createState() => _PriceCategoryListState();
}

class _PriceCategoryListState extends State<PriceCategoryList> {
  String _search = '';
  String _sort = 'updated';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watch = WatchPriceByCategory(PriceRepositoryImpl());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // 検索バー
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchHint,
                  ),
                  // 入力文字列に応じてリストをフィルタリング
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              // 並び替えドロップダウン。選択変更で並び替えを実行
              DropdownButton<String>(
                value: _sort,
                onChanged: (v) => setState(() => _sort = v!),
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
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<PriceInfo>>(
            stream: watch(widget.category),
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
              final Map<String, PriceInfo> map = {};
              for (final p in list) {
                final current = map[p.itemType];
                if (current == null || p.unitPrice < current.unitPrice) {
                  map[p.itemType] = p;
                }
              }
              // 商品名だけでなくカテゴリ名・品種名も検索対象に含める
              var items = map.values
                  .where((e) =>
                      e.itemName.contains(_search) ||
                      e.category.contains(_search) ||
                      e.itemType.contains(_search))
                  .toList();
              // 選択された並び替え順に従ってソート
              if (_sort == 'alphabet') {
                items.sort((a, b) => a.itemType.compareTo(b.itemType));
              } else {
                items.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(AppLocalizations.of(context)!.itemName)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.count)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.unit)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.volume)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.totalVolumeLabel)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.price)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.shop)),
                      DataColumn(label: Text(AppLocalizations.of(context)!.unitPriceLabel)),
                    ],
                    rows: [
                      for (final p in items)
                        DataRow(
                          cells: [
                            DataCell(Text(p.itemName)),
                            DataCell(Text(p.count.toString())),
                            DataCell(Text(p.unit)),
                            DataCell(Text(p.volume.toString())),
                            DataCell(Text(p.totalVolume.toString())),
                            DataCell(Text(p.price.toString())),
                            DataCell(Text(p.shop)),
                            DataCell(Text(p.unitPrice.toStringAsFixed(2))),
                          ],
                          onSelectChanged: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PriceHistoryPage(
                                  category: widget.category,
                                  itemType: p.itemType,
                                ),
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
