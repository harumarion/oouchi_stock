import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/entities/history_entry.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category.dart';
import 'edit_inventory_page.dart';


// 商品詳細画面。履歴と予測日を表示する
class InventoryDetailPage extends StatelessWidget {
  /// 表示対象の在庫ID
  final String inventoryId;
  /// カテゴリ一覧
  final List<Category> categories;
  /// 在庫リポジトリ
  final InventoryRepository repository;

  InventoryDetailPage({
    super.key,
    required this.inventoryId,
    required this.categories,
    InventoryRepository? repository,
  }) : repository = repository ?? InventoryRepositoryImpl();

  /// 指定IDの在庫を監視するストリームを返す
  Stream<Inventory?> inventoryStream() {
    return repository.watchInventory(inventoryId);
  }

  /// 在庫履歴を監視するストリームを返す
  Stream<List<HistoryEntry>> historyStream() {
    return repository.watchHistory(inventoryId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Inventory?>(
      stream: inventoryStream(),
      builder: (context, invSnapshot) {
        if (invSnapshot.hasError) {
          final err = invSnapshot.error?.toString() ?? 'unknown';
          return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.loadError(err))),
          );
        }
        if (!invSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final inv = invSnapshot.data;
        if (inv == null) {
          return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.loadError('not found'))),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(inv.itemName), actions: [
            // 編集ボタン。押すと編集画面へ遷移する
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
              DateTime predicted;
              if (inv.monthlyConsumption <= 0) {
                predicted = DateTime.now();
              } else {
                final days =
                    (inv.quantity / inv.monthlyConsumption * 30).ceil();
                predicted = DateTime.now().add(Duration(days: days));
              }
              final textStyle = Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 18);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailRow(
                    AppLocalizations.of(context)!.category,
                    inv.category,
                    textStyle,
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context)!.itemType,
                    inv.itemType,
                    textStyle,
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context)!.quantity,
                    '${inv.quantity.toStringAsFixed(1)}${inv.unit}',
                    textStyle,
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context)!.monthlyConsumption,
                    inv.monthlyConsumption.toStringAsFixed(1),
                    textStyle,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    AppLocalizations.of(context)!.predictLabel,
                    _formatDate(predicted),
                    textStyle,
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.history,
                      style: const TextStyle(fontSize: 18)),
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


  /// 項目名と値を左右に表示する行を生成
  Widget _buildDetailRow(String label, String value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // 日付を "yyyy/MM/dd HH:mm" 形式で返す
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  /// 履歴表示用のタイルを作成する。
  Widget _buildHistoryTile(HistoryEntry e, String unit) {
    final diffSign = e.diff >= 0 ? '+' : '-';
    final quantityText =
        '${e.before.toStringAsFixed(1)} -> ${e.after.toStringAsFixed(1)} ($diffSign${e.diff.abs().toStringAsFixed(1)}$unit)';
    final color = e.diff >= 0 ? Colors.green : Colors.red;
    final style = const TextStyle(fontSize: 18);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(_formatDate(e.timestamp), style: style)),
            Expanded(child: Center(child: Text(_typeLabel(e.type), style: style))),
            Expanded(
              child: Text(
                quantityText,
                textAlign: TextAlign.right,
                style: style.copyWith(color: color),
              ),
            ),
          ],
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  /// 操作種別を日本語で返す
  String _typeLabel(String type) {
    switch (type) {
      case 'stocktake':
        return '棚卸';
      case 'add':
        return '追加';
      case 'bought':
        return '購入';
      case 'used':
        return '使用';
      default:
        return type;
    }
  }
}
