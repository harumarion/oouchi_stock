import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';
import '../util/inventory_display.dart';
import '../util/buy_item_reason_label.dart';
import 'item_card.dart';
import 'card_menu_button.dart';

/// 買い物予報画面で使用するカードウィジェット
/// 右スワイプで予報リストから削除できる
///
/// 画面名: PredictionPage
/// スワイプで削除、ボタンで買い物リストへ追加する処理を持つ
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

  /// メニューボタン押下時に表示するボトムシート
  ///
  /// 買い物予報画面では「買い物リストへ追加」のみ表示する
  void _showActions(BuildContext context, Inventory inv) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 買い物リストへ追加
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text(loc.addToBuyList),
            onTap: () async {
              Navigator.pop(context);
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_removed) return const SizedBox.shrink();
    return ItemCard(
      key: ValueKey(widget.item.key),
      dismissDirection: DismissDirection.startToEnd,
      onDismissed: (_) {
        setState(() { _removed = true; });
        widget.removePrediction(widget.item);
      },
      child: StreamBuilder<Inventory?>(
        stream: widget.watchInventory(widget.item.inventoryId!),
        builder: (context, snapshot) {
          // 在庫がまだ取得できない場合もカードとして表示する
          if (!snapshot.hasData) {
            return ListTile(
              title: Text(
                widget.item.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // 詳細画面へ遷移するタップイベント
              onTap: () => _openDetail(context),
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

              return ListTile(
                // 商品名と品種の表示
                title: Text(
                  '${inv.itemName} / ${inv.itemType}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    Text(
                      widget.item.reason.label(loc),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                // タップで在庫詳細を開く
                onTap: () => _openDetail(context),
                // メニューボタンを押すとボトムシートで操作一覧を表示
                trailing: CardMenuButton(
                  onPressed: () => _showActions(context, inv),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
