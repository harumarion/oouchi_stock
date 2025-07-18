import 'package:flutter/material.dart';

/// カテゴリ追加・編集画面で使用するカラー選択ウィジェット
/// 画面名: カテゴリ登録・編集ページ
class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;
  const ColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final c in colors)
            GestureDetector(
              onTap: () => onSelected(c),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == c ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
