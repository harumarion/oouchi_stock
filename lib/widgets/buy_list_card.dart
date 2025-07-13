import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
// 残り日数計算や在庫監視などは外部から関数として受け取る
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';
import '../util/inventory_display.dart';

/// BuyListPage で使用される、買い物リストを表示するカードウィジェット
class BuyListCard extends StatelessWidget {
  /// 表示する買い物データ
  final BuyItem item;
  /// カテゴリ一覧。詳細画面遷移に利用する
  final List<Category> categories;

  /// 在庫監視関数
  final Stream<Inventory?> Function(String id) watchInventory;

  /// 残り日数計算関数
  final Future<int> Function(Inventory inv) calcDaysLeft;

  /// 在庫数を更新する関数
  final Future<void> Function(String id, double amount, String type)
      updateQuantity;

  /// 削除処理を実行するユースケース
  final void Function(BuyItem item) onRemove;

  const BuyListCard({
    super.key,
    required this.item,
    required this.categories,
    // 在庫情報をリアルタイムで取得する関数
    required this.watchInventory,
    // 在庫から残り日数を計算する関数
    required this.calcDaysLeft,
    // 在庫数量を更新する関数
    required this.updateQuantity,
    required this.onRemove,
  });

  /// 削除時の数量入力ダイアログを表示
  Future<double?> _inputAmountDialog(BuildContext context) async {
    final controller = TextEditingController(text: '1');
    return showDialog<double>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          void add() {
            final v = double.tryParse(controller.text) ?? 0;
            controller.text = (v + 1).toStringAsFixed(0);
            setState(() {});
          }

          void remove() {
            final v = double.tryParse(controller.text) ?? 0;
            if (v > 0) controller.text = (v - 1).toStringAsFixed(0);
            setState(() {});
          }

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.boughtAmount),
            content: Row(
              children: [
                IconButton(onPressed: remove, icon: const Icon(Icons.remove)),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                IconButton(onPressed: add, icon: const Icon(Icons.add)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  final v = double.tryParse(controller.text);
                  Navigator.pop(context, v);
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        });
      },
    );
  }

  /// カードを右スワイプしたときに呼ばれる削除確認処理
  Future<bool> _confirmDismiss(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    if (item.inventoryId != null) {
      // 在庫と紐づく場合、購入数を入力してから削除
      final v = await _inputAmountDialog(context);
      if (v == null) return false;
      try {
        await updateQuantity(item.inventoryId!, v, 'bought');
      } catch (_) {
        // 更新失敗時はスナックバーで通知
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.updateFailed)));
        return false;
      }
      return true;
    }
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(loc.confirmDelete),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(loc.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 在庫詳細画面へ遷移する処理
  void _openDetail(BuildContext context) {
    if (item.inventoryId == null) return;
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
      confirmDismiss: (_) => _confirmDismiss(context),
      onDismissed: (_) => onRemove(item),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: item.inventoryId == null
            // 手入力アイテムは商品名のみ表示
            ? ListTile(title: Text(item.name))
            : StreamBuilder<Inventory?>(
                stream: watchInventory(item.inventoryId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text(item.name),
                      // 詳細画面へ遷移するタップイベント
                      onTap: () => _openDetail(context),
                    );
                  }
                  final inv = snapshot.data!;
                  return FutureBuilder<int>(
                    future: calcDaysLeft(inv),
                    builder: (context, daysSnapshot) {
                      final daysText = daysSnapshot.hasData
                          ? ' ・ ${loc.daysLeft(daysSnapshot.data!.toString())}'
                          : '';
                      // 数量は単位を付けずに表示 -> 新関数でローカライズ
                      // 買い物リスト画面のカードで在庫数量と総容量をまとめて表示
                      final subtitle =
                          '${formatRemaining(context, inv)}$daysText';
                      return ListTile(
                        // 商品名の後ろに品種を表示
                        title: Text('${inv.itemName} / ${inv.itemType}'),
                        subtitle: Text(subtitle),
                        onTap: () => _openDetail(context),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
