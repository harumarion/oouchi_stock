import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_price_page.dart';
import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/watch_price_by_category.dart';
import 'price_history_page.dart';

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
    FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _categories = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
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
        appBar: AppBar(title: Text(AppLocalizations.of(context).priceManagementTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).priceManagementTitle),
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

class PriceCategoryList extends StatelessWidget {
  final String category;
  const PriceCategoryList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final watch = WatchPriceByCategory(PriceRepositoryImpl());
    return StreamBuilder<List<PriceInfo>>(
      stream: watch(category),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error?.toString() ?? 'unknown';
          return Center(child: Text(AppLocalizations.of(context).loadError(err)));
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
        final items = map.values.toList()
          ..sort((a, b) => a.itemType.compareTo(b.itemType));
        return ListView(
          children: [
            for (final p in items)
              ListTile(
                title: Text(p.itemName),
                subtitle: Text(
                    AppLocalizations.of(context).priceSummary(
                      count: p.count.toString(),
                      unitStr: p.unit,
                      volume: p.volume.toString(),
                      total: p.totalVolume.toString(),
                      price: p.price.toString(),
                      shop: p.shop,
                      unitPrice: p.unitPrice.toStringAsFixed(2),
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PriceHistoryPage(
                        category: category,
                        itemType: p.itemType,
                      ),
                    ),
                  );
                },
              )
          ],
        );
      },
    );
  }
}
