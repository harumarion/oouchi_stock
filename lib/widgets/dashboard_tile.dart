import 'package:flutter/material.dart';
import '../domain/entities/inventory.dart';
import '../i18n/app_localizations.dart';

/// ホーム画面のダッシュボードで使用するタイル
class DashboardTile extends StatelessWidget {
  final Inventory inventory;
  final int daysLeft;
  final bool onSale;
  final VoidCallback onAdd;

  const DashboardTile({
    super.key,
    required this.inventory,
    required this.daysLeft,
    required this.onSale,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // 残日数に応じて枠線の色を変える
    Color borderColor = Colors.grey;
    if (inventory.quantity <= 0 || daysLeft <= 0) {
      borderColor = Colors.red;
    } else if (daysLeft <= 3) {
      borderColor = Colors.orange;
    } else if (onSale) {
      borderColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            inventory.itemName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // 残り日数をローカライズして表示
          Text(AppLocalizations.of(context)!.daysLeft(daysLeft.toString())),
          const SizedBox(height: 4),
          Text('${inventory.quantity.toStringAsFixed(1)}${inventory.unit}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onAdd,
            child: Text(AppLocalizations.of(context)!.addToBuyList),
          ),
        ],
      ),
    );
  }
}
