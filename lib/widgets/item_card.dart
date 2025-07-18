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
    final card = Card(
      margin: const EdgeInsets.only(bottom: 12),
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
