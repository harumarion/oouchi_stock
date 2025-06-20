import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/history_entry.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'domain/services/purchase_prediction_strategy.dart';
import 'edit_inventory_page.dart';


// 商品詳細画面。履歴と予測日を表示する
class InventoryDetailPage extends StatelessWidget {
  final String inventoryId;
  final List<Category> categories;
  final PurchasePredictionStrategy strategy;
  final InventoryRepositoryImpl repository = InventoryRepositoryImpl();

  InventoryDetailPage({
    super.key,
    required this.inventoryId,
    required this.categories,
    this.strategy = const DummyPredictionStrategy(),
  });

  Stream<Inventory?> inventoryStream() {
    return repository.watchInventory(inventoryId);
  }

  Stream<List<HistoryEntry>> historyStream() {
    return repository.watchHistory(inventoryId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Inventory?>(
      stream: inventoryStream(),
      builder: (context, invSnapshot) {
        if (!invSnapshot.hasData) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final inv = invSnapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(inv.itemName), actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditInventoryPage(
                      id: inventoryId,
                      itemName: inv.itemName,
                      category: categories.firstWhere(
                        (e) => e.name == inv.category,
                        orElse: () => Category(
                          id: 0,
                          name: inv.category,
                          createdAt: DateTime.now(),
                          color: null,
                        ),
                      ),
                      itemType: inv.itemType,
                      unit: inv.unit,
                      note: inv.note,
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
                  Text('${AppLocalizations.of(context)!.category}: ${inv.category}'),
                  Text('${AppLocalizations.of(context)!.itemType}: ${inv.itemType}'),
                  Text('${AppLocalizations.of(context)!.quantity}: ${inv.quantity.toStringAsFixed(1)}${inv.unit}'),
                  const SizedBox(height: 8),
                  Text('${AppLocalizations.of(context)!.predictLabel} ${_formatDate(predicted)}'),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.history, style: const TextStyle(fontSize: 18)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: ListView(
                      children:
                          list.map((e) => _buildHistoryTile(e, inv.unit)).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
  Widget _buildHistoryTile(HistoryEntry e, String unit) {
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
