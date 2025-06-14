import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 棚卸入力用のデータ保持クラス
class _StockItem {
  final DocumentReference<Map<String, dynamic>> ref;
  final String name;
  final TextEditingController controller;
  final double original;

  _StockItem(this.ref, this.name, double quantity)
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .orderBy('createdAt')
        .get();
    setState(() {
      _items.clear();
      for (final doc in snapshot.docs) {
        final q = (doc['quantity'] ?? 0).toDouble();
        final name = doc['itemName'] ?? doc.id;
        _items.add(_StockItem(doc.reference, name, q));
      }
    });
  }

  Future<void> _save() async {
    for (final item in _items) {
      final value = double.tryParse(item.controller.text) ?? 0;
      final before = item.original;
      final diff = value - before;
      await item.ref.update({'quantity': value});
      await item.ref.collection('history').add({
        'type': 'stocktake',
        'before': before,
        'after': value,
        'diff': diff,
        'timestamp': Timestamp.now(),
      });
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
