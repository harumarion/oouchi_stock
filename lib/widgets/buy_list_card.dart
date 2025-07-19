import 'package:flutter/material.dart';
import '../domain/entities/buy_item.dart';
import '../domain/entities/category.dart';
import '../domain/entities/inventory.dart';
// 残り日数計算や在庫監視などは外部から関数として受け取る
import '../i18n/app_localizations.dart';
import '../inventory_detail_page.dart';
import '../util/inventory_display.dart';
import '../util/buy_item_reason_label.dart';
import 'item_card.dart';
import 'number_text_form_field.dart';

/// BuyListPage で使用される、買い物リストを表示するカードウィジェット
///
/// 画面名: BuyListPage
/// スワイプで削除、タップで在庫詳細画面へ遷移するイベントを管理
class BuyListCard extends StatefulWidget {
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

  @override
  State<BuyListCard> createState() => _BuyListCardState();
}

class _BuyListCardState extends State<BuyListCard> {
  /// 削除済みフラグ
  bool _removed = false;

  /// 削除時の数量入力ダイアログを表示
  Future<double?> _inputAmountDialog(BuildContext context) async {
    String value = '1';
    return showDialog<double>(
      context: context,
      builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            void add() {
              final v = double.tryParse(value) ?? 0;
              setState(() => value = (v + 1).toStringAsFixed(0));
            }

            void remove() {
              final v = double.tryParse(value) ?? 0;
              if (v > 0) {
                setState(() => value = (v - 1).toStringAsFixed(0));
              }
            }

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.boughtAmount),
            content: Row(
              children: [
                IconButton(onPressed: remove, icon: const Icon(Icons.remove)),
                Expanded(
                  child: NumberTextFormField(
                    key: ValueKey(value),
                    label: '',
                    initial: value,
                    onChanged: (v) => value = v,
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
                  final v = double.tryParse(value);
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

  /// 長押しで購入数入力ダイアログを表示し在庫を更新
  Future<void> _onLongPress(BuildContext context) async {
    if (widget.item.inventoryId == null) return;
    final v = await _inputAmountDialog(context);
    if (v == null) return;
    try {
      await widget.updateQuantity(widget.item.inventoryId!, v, 'bought');
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.updateFailed)));
    }
  }

  /// カードを右スワイプしたときに呼ばれる削除確認処理
  Future<bool> _confirmDismiss(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    if (widget.item.inventoryId != null) {
      // 在庫と紐づく場合、購入数を入力してから削除
      final v = await _inputAmountDialog(context);
      if (v == null) return false;
      try {
        await widget.updateQuantity(widget.item.inventoryId!, v, 'bought');
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
    if (widget.item.inventoryId == null) return;
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

  /// 手入力アイテム用タイル
  Widget _buildManualTile(BuildContext context, AppLocalizations loc) {
    return ListTile(
      title: Text(
        widget.item.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        widget.item.reason.label(loc),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onLongPress: () => _onLongPress(context),
    );
  }
  Widget _buildInventoryTile(
      BuildContext context, Inventory inv, int days, AppLocalizations loc) {
    final subtitle =
        '${formatRemaining(context, inv)} ・ ${loc.daysLeft(days.toString())}';
    return ListTile(
      title: Text(
        '${inv.itemName} / ${inv.itemType}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
          ),
          Text(
            widget.item.reason.label(loc),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _openDetail(context),
      onLongPress: () => _onLongPress(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_removed) return const SizedBox.shrink();
    return ItemCard(
      key: ValueKey(widget.item.key),
      dismissDirection: DismissDirection.startToEnd,
      confirmDismiss: (_) => _confirmDismiss(context),
      onDismissed: (_) {
        setState(() {
          _removed = true;
        });
        widget.onRemove(widget.item);
      },
      child: widget.item.inventoryId == null
            ? _buildManualTile(context, loc)
            : StreamBuilder<Inventory?>(
                stream: widget.watchInventory(widget.item.inventoryId!),
                builder: (context, snapshot) {
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
                      final days = daysSnapshot.data ?? 0;
                      return _buildInventoryTile(context, inv, days, loc);
                    },
                  );
                },
              ),
    );
  }
}
