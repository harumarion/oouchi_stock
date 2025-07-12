import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';

/// 買い物予報画面で使用するカードウィジェット
/// 右スワイプで予報リストから削除できる
class PredictionCard extends StatelessWidget {
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

  /// 在庫詳細画面を開く
  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryDetailPage(
          inventoryId: item.inventoryId!,
          categories: categories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => removePrediction(item),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: StreamBuilder<Inventory?>(
        stream: watchInventory(item.inventoryId!),
        builder: (context, snapshot) {
          // 在庫がまだ取得できない場合もカードとして表示する
          if (!snapshot.hasData) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(item.name),
                // 詳細画面へ遷移するタップイベント
                onTap: () => _openDetail(context),
              ),
            );
          }
          final inv = snapshot.data!;
          return FutureBuilder<int>(
            future: calcDaysLeft(inv),
            builder: (context, daysSnapshot) {
              final daysText = daysSnapshot.hasData
                  ? ' ・ ${loc.daysLeft(daysSnapshot.data!.toString())}'
                  : '';
              // 数量は単位を付けずに表示
              final subtitle =
                  '${inv.quantity.toStringAsFixed(1)}$daysText';
              return Card(
                // 買い物予報画面の1アイテムをカード表示
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  // 商品名の後に品種を表示する
                  title: Text('${inv.itemName} / ${inv.itemType}'),
                  subtitle: Text(subtitle),
                  onTap: () => _openDetail(context),
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () async {
                      await addToBuyList(
                          BuyItem(inv.itemName, inv.category, inv.id));
                      await removePrediction(item);
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
