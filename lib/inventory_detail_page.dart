import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/history_entry.dart';
import 'domain/services/purchase_prediction_strategy.dart';
import 'edit_inventory_page.dart';


// 商品詳細画面。履歴と予測日を表示する
class InventoryDetailPage extends StatelessWidget {
  final String inventoryId;
  final String itemName;
  final String unit;
  final String category;
  final String itemType;
  final double quantity;
  final PurchasePredictionStrategy strategy;
  final InventoryRepositoryImpl repository = InventoryRepositoryImpl();

  InventoryDetailPage({
    super.key,
    required this.inventoryId,
    required this.itemName,
    required this.unit,
    required this.category,
    required this.itemType,
    required this.quantity,
    this.strategy = const DummyPredictionStrategy(),
  });

  Stream<List<HistoryEntry>> historyStream() {
    return repository.watchHistory(inventoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itemName), actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditInventoryPage(
                  id: inventoryId,
                  itemName: itemName,
                  category: category,
                  itemType: itemType,
                  unit: unit,
                  note: '',
                ),
              ),
            );
          },
        )
      ]),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: historyStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          final predicted =
              strategy.predict(DateTime.now(), list, _currentQuantity(list));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('カテゴリ: $category'),
              Text('品種: $itemType'),
              Text('在庫: ${quantity.toStringAsFixed(1)}$unit'),
              const SizedBox(height: 8),
              Text('次回購入予測: ${_formatDate(predicted)}'),
              const SizedBox(height: 16),
              const Text('履歴', style: TextStyle(fontSize: 18)),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: ListView(
                  children: list.map(_buildHistoryTile).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _currentQuantity(List<HistoryEntry> history) {
    if (history.isEmpty) return 0;
    double total = 0;
    for (final h in history.reversed) {
      if (h.type == 'stocktake') {
        total = h.after;
      } else if (h.type == 'add' || h.type == 'bought') {
        total += h.quantity;
      } else if (h.type == 'used') {
        total -= h.quantity;
      }
    }
    return total;
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  /// 履歴表示用のタイルを作成する。
  Widget _buildHistoryTile(HistoryEntry e) {
    String title;
    Color color = Colors.black;
    if (e.type == 'stocktake') {
      final sign = e.diff >= 0 ? '+' : '-';
      title =
          '棚卸 ${e.before.toStringAsFixed(1)} -> ${e.after.toStringAsFixed(1)} ($sign${e.diff.abs().toStringAsFixed(1)}$unit)';
      color = e.diff >= 0 ? Colors.green : Colors.red;
    } else if (e.type == 'add' || e.type == 'bought') {
      title = '+${e.quantity.toStringAsFixed(1)}$unit';
      color = Colors.green;
    } else if (e.type == 'used') {
      title = '-${e.quantity.toStringAsFixed(1)}$unit';
      color = Colors.red;
    } else {
      title = '${e.quantity.toStringAsFixed(1)}$unit';
    }
    return ListTile(
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(_formatDate(e.timestamp)),
    );
  }
}
