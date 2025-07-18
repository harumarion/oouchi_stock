import 'package:flutter/material.dart';

/// データ未登録時の案内表示を行うウィジェット
/// 画面名: 各種ページ共通
class EmptyState extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  const EmptyState({
    super.key,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (buttonLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
