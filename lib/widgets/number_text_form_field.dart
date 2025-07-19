import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 汎用の数値入力フォームフィールド
/// 画面名: 各種設定画面やダイアログで利用
class NumberTextFormField extends StatelessWidget {
  /// ラベルテキスト
  final String label;

  /// 初期値
  final String initial;

  /// 値変更時のコールバック
  final ValueChanged<String> onChanged;

  /// バリデーション処理
  final FormFieldValidator<String>? validator;

  const NumberTextFormField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initial = '',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
