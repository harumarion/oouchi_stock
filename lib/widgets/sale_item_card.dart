import "../i18n/app_localizations.dart";
import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../models/sale_item.dart';
import '../util/localization_extensions.dart';
import 'item_card.dart';

/// セール情報画面で使用するカードウィジェット
///
/// 画面名: SaleListPage
/// セール商品を買い物リストへ追加するボタンの処理を持つ
class SaleItemCard extends StatelessWidget {
  /// 表示するセール情報
  final SaleItem item;
  /// 買い物リストへ追加する処理
  final Future<void> Function(BuyItem item) onAdd;

  const SaleItemCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final daysLeft = item.end.difference(DateTime.now()).inDays;
    final expired = daysLeft <= 1;
    final period =
        '${item.start.month}/${item.start.day}〜${item.end.month}/${item.end.day}';
    return ItemCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    // 商品名の後ろに品種を表示する
                    '${item.name} / ${item.itemType}',
                    // カードタイトル用フォントを適用
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (item.recommended)
                  const Icon(Icons.notifications_active, color: Colors.orange),
                if (item.lowest)
                  const Icon(Icons.price_check, color: Colors.red),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.shop,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              '${loc.salePriceLabel(item.salePrice.toStringAsFixed(0))}  '
              '${loc.regularPriceLabel(item.regularPrice.toStringAsFixed(0))}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              loc.salePeriod(period),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              loc.daysLeft(daysLeft.toString()),
              // 残り日数表示は bodyMedium
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      color: expired ? Colors.red : Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // 在庫数表示と合わせてアイコンを配置
                if (item.stock <= 0)
                  const Icon(Icons.inventory_2, color: Colors.red)
                else if (item.stock <= 3)
                  const Icon(Icons.inventory_2, color: Colors.orange)
                else
                  const Icon(Icons.inventory_2, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  loc.stockInfo(item.stock),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  await onAdd(
                      BuyItem(item.name, '', null, BuyItemReason.sale));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.addedBuyItem)),
                    );
                  }
                },
                child: Text(loc.addToList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
