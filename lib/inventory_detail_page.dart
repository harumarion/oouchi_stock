import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 履歴データを保持するクラス
class HistoryEntry {
  final String type;
  final double quantity;
  final Timestamp timestamp;
  final double before;
  final double after;
  final double diff;

  HistoryEntry(this.type, this.quantity, this.timestamp,
      {this.before = 0, this.after = 0, this.diff = 0});
}

// 購入予測アルゴリズムの Strategy インターフェイス
abstract class PurchasePredictionStrategy {
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity);
}

// 現状は仮の実装。常に一週間後を返す
class DummyPredictionStrategy implements PurchasePredictionStrategy {
  const DummyPredictionStrategy();
  @override
  DateTime predict(DateTime now, List<HistoryEntry> history, double quantity) {
    return now.add(const Duration(days: 7));
  }
}

// 商品詳細画面。履歴と予測日を表示する
class InventoryDetailPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String itemName;
  final String unit;
  final PurchasePredictionStrategy strategy;

  const InventoryDetailPage({
    super.key,
    required this.docRef,
    required this.itemName,
    required this.unit,
    this.strategy = const DummyPredictionStrategy(),
  });

  Stream<List<HistoryEntry>> historyStream() {
    return docRef
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => HistoryEntry(
                  d['type'] ?? '',
                  (d['quantity'] ?? 0).toDouble(),
                  d['timestamp'] as Timestamp,
                  before: (d['before'] ?? 0).toDouble(),
                  after: (d['after'] ?? 0).toDouble(),
                  diff: (d['diff'] ?? 0).toDouble(),
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itemName)),
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
              Text('次回購入予測: ${_formatDate(predicted)}'),
              const SizedBox(height: 16),
              const Text('履歴', style: TextStyle(fontSize: 18)),
              ...list.map(_buildHistoryTile),
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
      subtitle: Text(_formatDate(e.timestamp.toDate())),
    );
  }
}
