import 'package:flutter/material.dart';

import '../domain/entities/inventory.dart';
import '../util/item_type_localization.dart';

/// 在庫を選択する共通ドロップダウン
/// セール情報追加画面や編集画面で利用される
class InventoryDropdown extends StatelessWidget {
  /// ドロップダウンのラベル
  final String label;

  /// 表示する在庫一覧
  final List<Inventory> inventories;

  /// 選択中の在庫
  final Inventory? value;

  /// 選択変更時のコールバック
  final ValueChanged<Inventory?> onChanged;

  const InventoryDropdown({
    super.key,
    required this.label,
    required this.inventories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Inventory>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: inventories
          .map(
            (e) => DropdownMenuItem(
              value: e,
              // 商品名 / 品種 の順で表示する
              child: Text('${e.itemName} / ${localizeItemType(context, e.itemType)}'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
