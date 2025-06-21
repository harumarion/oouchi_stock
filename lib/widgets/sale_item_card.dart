import "../i18n/app_localizations.dart";
import 'package:flutter/material.dart';
import '../domain/usecases/add_buy_item.dart';
import '../domain/entities/buy_item.dart';
import '../models/sale_item.dart';
import '../util/localization_extensions.dart';

/// セール情報画面で使用するカードウィジェット
class SaleItemCard extends StatelessWidget {
  /// 表示するセール情報
  final SaleItem item;
  /// 買い物リスト追加ユースケース
  final AddBuyItem addUsecase;

  const SaleItemCard({
    super.key,
    required this.item,
    required this.addUsecase,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final daysLeft = item.end.difference(DateTime.now()).inDays;
    final expired = daysLeft <= 1;
    final period =
        '${item.start.month}/${item.start.day}〜${item.end.month}/${item.end.day}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.recommended)
                  const Icon(Icons.notifications_active, color: Colors.orange),
                if (item.lowest)
                  const Icon(Icons.price_check, color: Colors.red),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.shop),
            const SizedBox(height: 4),
            Text(
              '${loc.salePriceLabel(item.salePrice.toStringAsFixed(0))}  '
              '${loc.regularPriceLabel(item.regularPrice.toStringAsFixed(0))}',
            ),
            const SizedBox(height: 4),
            Text(loc.salePeriod(period)),
            const SizedBox(height: 4),
            Text(
              loc.daysLeft(daysLeft.toString()),
              style: TextStyle(color: expired ? Colors.red : null),
            ),
            const SizedBox(height: 4),
            Text(loc.stockInfo(item.stock)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  await addUsecase(BuyItem(item.name, ''));
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
