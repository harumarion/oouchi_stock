import 'package:flutter/material.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/usecases/fetch_all_inventory.dart';
import 'domain/usecases/stocktake.dart';

// 棚卸入力用のデータ保持クラス
class _StockItem {
  final String id;
  final String name;
  final TextEditingController controller;
  final double original;

  _StockItem(this.id, this.name, double quantity)
      : original = quantity,
        controller = TextEditingController(text: quantity.toStringAsFixed(1));
}

// 棚卸画面
class StocktakePage extends StatefulWidget {
  const StocktakePage({super.key});

  @override
  State<StocktakePage> createState() => _StocktakePageState();
}

class _StocktakePageState extends State<StocktakePage> {
  final List<_StockItem> _items = [];
  final repository = InventoryRepositoryImpl();
  late final FetchAllInventory _fetch;
  late final Stocktake _stocktake;

  @override
  void initState() {
    super.initState();
    _fetch = FetchAllInventory(repository);
    _stocktake = Stocktake(repository);
    _load();
  }

  Future<void> _load() async {
    final list = await _fetch();
    setState(() {
      _items
        ..clear()
        ..addAll(list.map((inv) => _StockItem(inv.id, inv.itemName, inv.quantity)));
    });
  }

  Future<void> _save() async {
    for (final item in _items) {
      final value = double.tryParse(item.controller.text) ?? 0;
      final before = item.original;
      final diff = value - before;
      await _stocktake(item.id, before, value, diff);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('棚卸入力')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: item.controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: item.name),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              await _save();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('保存'),
          )
        ],
      ),
    );
  }
}
