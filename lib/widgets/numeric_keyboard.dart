import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';

/// 数値入力用のキーパッドウィジェット
class NumericKeyboard extends StatelessWidget {
  /// 入力値を制御するコントローラー
  final TextEditingController controller;

  const NumericKeyboard({super.key, required this.controller});

  // ボタンを押したときの処理
  void _input(String value) {
    final text = controller.text + value;
    controller.text = text;
  }

  // バックスペース処理
  void _backspace() {
    final text = controller.text;
    if (text.isNotEmpty) {
      controller.text = text.substring(0, text.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '<',
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: buttons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) {
              final label = buttons[index];
              return ElevatedButton(
                onPressed: () {
                  if (label == '<') {
                    _backspace();
                  } else {
                    _input(label);
                  }
                },
                child: label == '<'
                    ? const Icon(Icons.backspace)
                    : Text(label, style: const TextStyle(fontSize: 20)),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.ok),
            ),
          ),
        ],
      ),
    );
  }
}

/// キーパッド付きの数値入力フィールド
class NumericTextFormField extends StatefulWidget {
  /// ラベルテキスト
  final String label;

  /// 初期値
  final String initial;

  /// 値変更時のコールバック
  final ValueChanged<String> onChanged;

  /// バリデーション処理
  final FormFieldValidator<String>? validator;

  const NumericTextFormField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initial = '',
    this.validator,
  });

  @override
  State<NumericTextFormField> createState() => _NumericTextFormFieldState();
}

class _NumericTextFormFieldState extends State<NumericTextFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
    _controller.addListener(() => widget.onChanged(_controller.text));
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      showModalBottomSheet(
        context: context,
        builder: (c) => NumericKeyboard(controller: _controller),
      ).whenComplete(() => _focusNode.unfocus());
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(labelText: widget.label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: true,
      validator: widget.validator,
    );
  }
}
