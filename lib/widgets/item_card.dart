import 'package:flutter/material.dart';

/// 複数画面で共通利用するカードのベースウィジェット
/// 画面名: 各種カード共通
class ItemCard extends StatelessWidget {
  final Widget child;
  final DismissDirection? dismissDirection;
  final Future<bool> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDismissed;
  const ItemCard({
    super.key,
    required this.child,
    this.dismissDirection,
    this.confirmDismiss,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    // どの画面でもカード幅を統一するため左右の余白は親ウィジェットで管理
    // カード間の縦方向の間隔のみここで定義する
    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
    if (dismissDirection != null) {
      return Dismissible(
        key: key ?? UniqueKey(),
        direction: dismissDirection!,
        confirmDismiss: confirmDismiss,
        onDismissed: onDismissed,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: card,
      );
    }
    return card;
  }
}
