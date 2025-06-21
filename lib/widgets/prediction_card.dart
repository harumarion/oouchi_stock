import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/usecases/add_buy_item.dart';
import '../domain/usecases/remove_prediction_item.dart';
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';

/// 買い物予報画面で使用するカードウィジェット
/// 右スワイプで予報リストから削除できる
class PredictionCard extends StatelessWidget {
  /// 表示するアイテム
  final BuyItem item;
  /// カテゴリ一覧。詳細画面遷移に利用する
  final List<Category> categories;
  /// 在庫リポジトリ
  final InventoryRepository repository;
  /// 買い物リスト追加ユースケース
  final AddBuyItem addUsecase;
  /// 予報リスト削除ユースケース
  final RemovePredictionItem removeUsecase;
  /// 残り日数計算処理
  final Future<int> Function(Inventory inv) calcDaysLeft;

  const PredictionCard({
    super.key,
    required this.item,
    required this.categories,
    required this.repository,
    required this.addUsecase,
    required this.removeUsecase,
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
      onDismissed: (_) => removeUsecase(item),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: StreamBuilder<Inventory?>(
        stream: repository.watchInventory(item.inventoryId!),
        builder: (context, snapshot) {
          final detailButton = IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _openDetail(context),
          );
          if (!snapshot.hasData) {
            return ListTile(title: Text(item.name), trailing: detailButton);
          }
          final inv = snapshot.data!;
          return FutureBuilder<int>(
            future: calcDaysLeft(inv),
            builder: (context, daysSnapshot) {
              final daysText = daysSnapshot.hasData
                  ? ' ・ ${loc.daysLeft(daysSnapshot.data!.toString())}'
                  : '';
              final subtitle =
                  '${inv.quantity.toStringAsFixed(1)}${inv.unit}$daysText';
              return ListTile(
                title: Text(item.name),
                subtitle: Text(subtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_add),
                      onPressed: () async {
                        await addUsecase(
                            BuyItem(inv.itemName, inv.category, inv.id));
                        await removeUsecase(item);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.addedBuyItem)),
                          );
                        }
                      },
                    ),
                    detailButton,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
