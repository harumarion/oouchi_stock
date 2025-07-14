import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';
import '../util/inventory_display.dart';
import '../util/buy_item_reason_label.dart';

/// 買い物予報画面で使用するカードウィジェット
/// 右スワイプで予報リストから削除できる
class PredictionCard extends StatefulWidget {
  /// 表示するアイテム
  final BuyItem item;
  /// カテゴリ一覧。詳細画面遷移に利用する
  final List<Category> categories;
  /// 在庫監視ストリーム取得
  final Stream<Inventory?> Function(String id) watchInventory;
  /// 買い物リストへ追加する処理
  final Future<void> Function(BuyItem item) addToBuyList;
  /// 予報リストから削除する処理
  final Future<void> Function(BuyItem item) removePrediction;
  /// 残り日数計算処理
  final Future<int> Function(Inventory inv) calcDaysLeft;

  const PredictionCard({
    super.key,
    required this.item,
    required this.categories,
    required this.watchInventory,
    required this.addToBuyList,
    required this.removePrediction,
    required this.calcDaysLeft,
  });

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  /// 削除後に非表示にするためのフラグ
  bool _removed = false;

  /// 在庫詳細画面を開く
  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryDetailPage(
          inventoryId: widget.item.inventoryId!,
          categories: widget.categories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_removed) return const SizedBox.shrink();
    return Dismissible(
      key: ValueKey(widget.item.key),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        setState(() {
          _removed = true;
        });
        widget.removePrediction(widget.item);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: StreamBuilder<Inventory?>(
        stream: widget.watchInventory(widget.item.inventoryId!),
        builder: (context, snapshot) {
          // 在庫がまだ取得できない場合もカードとして表示する
          if (!snapshot.hasData) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(widget.item.name),
                // 詳細画面へ遷移するタップイベント
                onTap: () => _openDetail(context),
              ),
            );
          }
          final inv = snapshot.data!;
          return FutureBuilder<int>(
                    future: widget.calcDaysLeft(inv),
            builder: (context, daysSnapshot) {
              final daysText = daysSnapshot.hasData
                  ? ' ・ ${loc.daysLeft(daysSnapshot.data!.toString())}'
                  : '';
              // 数量は単位を付けずに表示 -> 新関数でローカライズ
              // 予報画面カードで在庫数量と総容量をまとめて表示
              final subtitle =
                  '${formatRemaining(context, inv)}$daysText';
                      return Card(
                // 買い物予報画面の1アイテムをカード表示
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  // 商品名の後に品種を表示する
                        title: Text('${inv.itemName} / ${inv.itemType}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtitle),
                      Text(widget.item.reason.label(loc),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  onTap: () => _openDetail(context),
                  // 買い物リストへ追加するボタン
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () async {
                      await widget.addToBuyList(
                        BuyItem(inv.itemName, inv.category, inv.id,
                            BuyItemReason.prediction),
                      );
                      await widget.removePrediction(widget.item);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.addedBuyItem)),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
