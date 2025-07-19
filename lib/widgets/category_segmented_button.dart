import 'package:flutter/material.dart';

import '../domain/entities/category.dart';

/// カテゴリ切り替え用の共通 SegmentedButton
/// 画面名: 在庫一覧画面・買い物リスト画面・セール情報管理画面など
class CategorySegmentedButton extends StatelessWidget {
  /// 表示するカテゴリ一覧
  final List<Category> categories;

  /// 選択中のカテゴリインデックス
  final int index;

  /// 選択変更時のコールバック
  final ValueChanged<int> onChanged;

  const CategorySegmentedButton({
    super.key,
    required this.categories,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: [
        for (var i = 0; i < categories.length; i++)
          ButtonSegment<int>(
            value: i,
            label: Text(categories[i].name),
          )
      ],
      selected: {index},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
