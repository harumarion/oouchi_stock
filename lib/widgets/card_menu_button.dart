import 'package:flutter/material.dart';

/// カード右上に表示するメニューボタン
/// [onPressed] ボタンをタップしたときの処理
class CardMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CardMenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: onPressed,
    );
  }
}
