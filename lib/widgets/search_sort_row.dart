import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';

/// 検索バーと並び替えメニューをまとめたウィジェット
/// 画面名: 一覧共通コンポーネント
class SearchSortRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final String sortValue;
  final ValueChanged<String?> onSortChanged;
  final List<DropdownMenuItem<String>> items;
  final bool showExpiredSwitch;
  final bool showExpired;
  final ValueChanged<bool>? onShowExpiredChanged;
  const SearchSortRow({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.sortValue,
    required this.onSortChanged,
    required this.items,
    this.showExpiredSwitch = false,
    this.showExpired = false,
    this.onShowExpiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: loc.searchHint),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: sortValue,
          onChanged: onSortChanged,
          items: items,
        ),
        if (showExpiredSwitch) ...[
          const SizedBox(width: 8),
          Row(
            children: [
              Text(loc.showExpired),
              Switch(
                value: showExpired,
                onChanged: onShowExpiredChanged,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
