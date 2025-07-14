import "package:flutter/material.dart";
import "../i18n/app_localizations.dart";
import '../util/inventory_display.dart';
import "scrolling_text.dart"; // 長いテキストを流すウィジェット
import "../domain/entities/inventory.dart";

// 在庫カードウィジェット
// ホーム画面で1つの商品を表示し、数量操作などのボタンを提供する
class InventoryCard extends StatelessWidget {
  final Inventory inventory;
  /// 数量更新コールバック
  final Future<void> Function(String id, double amount, String type) updateQuantity;
  /// 棚卸しコールバック
  final Future<void> Function(String id, double before, double after, double diff) stocktake;
  final VoidCallback? onTap;
  // 購入ボタンのみ表示するかどうか
  final bool buyOnly;
  // 買い物リストへ追加するときのコールバック
  final VoidCallback? onAddToList;

  InventoryCard({
    super.key,
    required this.inventory,
    required this.updateQuantity,
    required this.stocktake,
    this.onTap,
    this.buyOnly = false,
    this.onAddToList,
  });

  /// 在庫データから購入予測日を計算する
  DateTime _predictFromInventory() {
    if (inventory.monthlyConsumption <= 0) {
      return DateTime.now();
    }
    final days =
        (inventory.totalVolume / inventory.monthlyConsumption * 30).ceil();
    return DateTime.now().add(Duration(days: days));
  }

  /// 予測日までの残り日数を計算する
  int _daysLeft(DateTime predicted) {
    final diff = predicted.difference(DateTime.now()).inDays;
    return diff >= 0 ? diff : 0;
  }

  /// 数量を入力させるダイアログを表示する
  Future<double?> _inputAmountDialog(
    BuildContext context,
    String title,
    {double initialValue = 1.0}
  ) async {
    final controller =
        TextEditingController(text: initialValue.toStringAsFixed(1));
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      },
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    double amount,
    String type,
  ) async {
    try {
      await updateQuantity(inventory.id, amount, type);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)),
      );
    }
  }

  /// 使った量ボタンをタップしたときの処理
  Future<void> onUsed(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.usedAmount,
    );
    if (v == null) return;
    await _updateQuantity(context, -v, 'used');
  }

  /// 買った量ボタンをタップしたときの処理
  Future<void> onBought(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.boughtAmount,
    );
    if (v == null) return;
    await _updateQuantity(context, v, 'bought');
  }

  /// 在庫ボタンをタップしたときの処理
  Future<void> onStock(BuildContext context) async {
    final v = await _inputAmountDialog(
      context,
      AppLocalizations.of(context)!.stockAmount,
      initialValue: inventory.quantity,
    );
    if (v == null) return;
    try {
      await stocktake(inventory.id, inventory.quantity, v, v - inventory.quantity);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ホーム画面や在庫一覧で表示される1商品のカードUI
    final predicted = _predictFromInventory();
    final dateText =
        AppLocalizations.of(context)!.daysLeft(_daysLeft(predicted).toString());
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 商品情報表示エリア。長すぎる文字列は ScrollingText で横に流す
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrollingText(
                        // 在庫カードでは商品名の後に品種を表示
                        '${inventory.itemName} / ${inventory.itemType}',
                        // カードタイトル用フォントを利用
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 4),
                    // 数量は単位を付けずに表示 -> 新関数でローカライズ
                    // 在庫一覧画面カードの数量と総容量をまとめて表示
                    Text(
                      formatRemaining(context, inventory),
                      // 在庫数などの情報には bodyMedium を使用
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                    // 予測ラベルを削除し、残り日数のみ表示する
                    Text(
                      dateText,
                      // 残り日数表示も同じく bodyMedium
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                  ],
                  ),
                ),
                // 操作ボタン。buyOnly=true のときは購入ボタンのみ表示
                Row(
                  children: [
                    if (!buyOnly) ...[
                      IconButton(
                        icon: const Text('📦', style: TextStyle(fontSize: 20)),
                        onPressed: () => onStock(context),
                      ),
                      IconButton(
                        icon: const Text('✂️', style: TextStyle(fontSize: 20)),
                        onPressed: () => onUsed(context),
                      ),
                    ],
                    IconButton(
                      // 買い物を意味するカートアイコン
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => onBought(context),
                    ),
                    if (onAddToList != null)
                      IconButton(
                        icon: const Icon(Icons.playlist_add),
                        onPressed: onAddToList,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}
