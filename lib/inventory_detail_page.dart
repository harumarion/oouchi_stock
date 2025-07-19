import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'presentation/viewmodels/inventory_detail_viewmodel.dart';
import 'domain/entities/category.dart';
import 'util/unit_localization.dart';
import 'edit_inventory_page.dart';
import 'domain/usecases/delete_inventory_with_relations.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'data/repositories/price_repository_impl.dart';
import 'data/repositories/buy_list_repository_impl.dart';
import 'data/repositories/buy_prediction_repository_impl.dart';

import "domain/entities/history_entry.dart";
import "domain/entities/inventory.dart";
import "domain/repositories/inventory_repository.dart";
/// 商品詳細画面。大きな商品画像と詳細情報、履歴を折りたたみ表示する
class InventoryDetailPage extends StatelessWidget {
  // 在庫詳細を取得する ViewModel
  final InventoryDetailViewModel viewModel;
  // カテゴリ一覧。プレースホルダー色の取得に利用
  final List<Category> categories;
  InventoryDetailPage({
    super.key,
    required String inventoryId, // 表示対象の在庫ID
    required this.categories, // カテゴリ一覧
    InventoryRepository? repository,
  }) : viewModel = InventoryDetailViewModel(inventoryId: inventoryId, repository: repository);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Inventory?>(
      stream: viewModel.inventoryStream(),
      builder: (context, invSnapshot) {
        if (invSnapshot.hasError) {
          final err = invSnapshot.error?.toString() ?? 'unknown';
          return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.loadError(err))));
        }
        if (!invSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final inv = invSnapshot.data;
        if (inv == null) {
          return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.loadError('not found'))));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(inv.itemName),
            actions: [
              // 画面右上のメニュー。編集・削除操作をまとめる
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    // 編集画面を開く
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditInventoryPage(
                          id: viewModel.inventoryId,
                          itemName: inv.itemName,
                          category: categories.firstWhere(
                            (e) => e.name == inv.category,
                            orElse: () => Category(id: 0, name: inv.category, createdAt: DateTime.now(), color: null),
                          ),
                          itemType: inv.itemType,
                          quantity: inv.quantity,
                          volume: inv.volume,
                          unit: inv.unit,
                          note: inv.note,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    final res = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Text(AppLocalizations.of(context)!.deleteConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      ),
                    );
                    if (res == true) {
                      try {
                        await DeleteInventoryWithRelations(
                          InventoryRepositoryImpl(),
                          PriceRepositoryImpl(),
                          BuyListRepositoryImpl(),
                          BuyPredictionRepositoryImpl(),
                        )(inv.id);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(AppLocalizations.of(context)!.edit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
              )
            ],
          ),
          body: StreamBuilder<List<HistoryEntry>>(
            stream: viewModel.historyStream(),
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
                    (inv.totalVolume / inv.monthlyConsumption * 30).ceil();
                predicted = DateTime.now().add(Duration(days: days));
              }
              final textStyle = Theme.of(context).textTheme.bodyLarge;
              Color color = Colors.grey;
              final cat = categories.firstWhere(
                (c) => c.name == inv.category,
                orElse: () => Category(
                  id: 0,
                  name: inv.category,
                  createdAt: DateTime.now(),
                  color: null,
                ),
              );
              if (cat.color != null) {
                color = Color(int.parse('ff${cat.color!.replaceFirst('#', '')}', radix: 16));
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 商品画像またはカテゴリカラーのプレースホルダー
                  Container(
                    key: const Key('itemImage'),
                    height: 200,
                    color: color,
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.category, style: textStyle),
                    trailing: Text(inv.category, style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.itemType, style: textStyle),
                    trailing: Text(inv.itemType, style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.quantity, style: textStyle),
                    trailing: Text(inv.quantity.toStringAsFixed(1), style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.volume, style: textStyle),
                    trailing: Text('${inv.volume.toStringAsFixed(1)}${localizeUnit(context, inv.unit)}', style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.totalVolumeLabel, style: textStyle),
                    trailing: Text('${inv.totalVolume.toStringAsFixed(1)}${localizeUnit(context, inv.unit)}', style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.monthlyConsumption, style: textStyle),
                    trailing: Text(inv.monthlyConsumption.toStringAsFixed(1), style: textStyle),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.predictLabel, style: textStyle),
                    trailing: Text(_formatDate(predicted), style: textStyle),
                  ),
                  ExpansionTile(
                    title: Text(AppLocalizations.of(context)!.history, style: textStyle),
                    children: [
                      for (final e in list)
                        _buildHistoryTile(context, e, localizeUnit(context, inv.unit)),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  /// 履歴エントリ1件を表示するウィジェット
  /// [context] 表示に利用する BuildContext
  /// [e] 履歴データ
  /// [unit] 容量の単位
  Widget _buildHistoryTile(
      BuildContext context, HistoryEntry e, String unit) {
    final diffSign = e.diff >= 0 ? '+' : '-';
    // 数量履歴は単位を付けずに表示
    final quantityText = '${e.before.toStringAsFixed(1)} -> ${e.after.toStringAsFixed(1)} ($diffSign${e.diff.abs().toStringAsFixed(1)})';
    final color = e.diff >= 0 ? Colors.green : Colors.red;
    // 履歴行のテキストスタイル
    final style = Theme.of(context).textTheme.bodyLarge!;
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
