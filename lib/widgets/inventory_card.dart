import "package:flutter/material.dart";
import "../i18n/app_localizations.dart";
import "../domain/entities/inventory.dart";
import "../domain/entities/history_entry.dart";
import "../domain/services/purchase_prediction_strategy.dart";
import "../domain/usecases/update_quantity.dart";
import "../domain/usecases/stocktake.dart";
import "../data/repositories/inventory_repository_impl.dart";
// 在庫カードウィジェット
// ホーム画面で1つの商品を表示し、数量操作などのボタンを提供する
class InventoryCard extends StatelessWidget {
  final Inventory inventory;
  final UpdateQuantity _update = UpdateQuantity(InventoryRepositoryImpl());
  final InventoryRepositoryImpl _repository = InventoryRepositoryImpl();
  final Stocktake _stocktake = Stocktake(InventoryRepositoryImpl());

  InventoryCard({
    super.key,
    required this.inventory,
  });

  /// 履歴を読み込み購入予測日を計算する。
  Future<DateTime> _loadPrediction() async {
    final list = await _repository.watchHistory(inventory.id).first;
    final strategy = const DummyPredictionStrategy();
    final predicted = strategy.predict(
        DateTime.now(), list, _currentQuantity(list));
    return predicted;
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

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }

  /// 数量を入力させるダイアログを表示する
  Future<double?> _inputAmountDialog(
    BuildContext context,
    String title,
    {double initialValue = 1.0}
  ) async {
    final controller =
        TextEditingController(text: initialValue.toStringAsFixed(1));
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text);
                Navigator.pop(context, v);
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    double amount,
    String type,
  ) async {
    try {
      await _update(inventory.id, amount, type);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)),
      );
    }
  }

  /// 使った量ボタンをタップしたときの処理
  Future<void> onUsed(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.usedAmount,
    );
    if (v == null) return;
    await _updateQuantity(context, -v, 'used');
  }

  /// 買った量ボタンをタップしたときの処理
  Future<void> onBought(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.boughtAmount,
    );
    if (v == null) return;
    await _updateQuantity(context, v, 'bought');
  }

  /// 在庫ボタンをタップしたときの処理
  Future<void> onStock(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.stockAmount,
      initialValue: inventory.quantity,
    );
    if (v == null) return;
    try {
      await _stocktake(inventory.id, inventory.quantity, v, v - inventory.quantity);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DateTime>(
      future: _loadPrediction(),
      builder: (context, snapshot) {
        final predicted = snapshot.data;
        final dateText = predicted != null
            ? _formatDate(predicted)
            : AppLocalizations.of(context)!.calculating;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${inventory.itemType} / ${inventory.itemName}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      '${inventory.quantity.toStringAsFixed(1)}${inventory.unit}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.predictLabel} $dateText',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Text('📦', style: TextStyle(fontSize: 20)),
                      onPressed: () => onStock(context),
                    ),
                    IconButton(
                      icon: const Text('✂️', style: TextStyle(fontSize: 20)),
                      onPressed: () => onUsed(context),
                    ),
                    IconButton(
                      icon: const Text('🛒', style: TextStyle(fontSize: 20)),
                      onPressed: () => onBought(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
