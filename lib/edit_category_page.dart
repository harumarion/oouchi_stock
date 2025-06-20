import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'util/firestore_refs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'domain/entities/category.dart';

/// カテゴリ名を編集する画面。
class EditCategoryPage extends StatefulWidget {
  final Category category;
  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  Color? _color;
  final _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
    if (widget.category.color != null) {
      final value = int.tryParse(widget.category.color!.replaceFirst('#', ''), radix: 16);
      if (value != null) _color = Color(0xFF000000 | value);
    }
  }

  /// 保存ボタンの処理
  Future<void> _save() async {
    try {
      final snapshot = await userCollection('categories')
          .where('id', isEqualTo: widget.category.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'name': _name,
          if (_color != null)
            'color': '#${_color!.value.toRadixString(16).padLeft(8, '0').substring(2)}'
          else
            'color': FieldValue.delete(),
        });
      }
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)))
          .closed;
      if (mounted) Navigator.pop(context, _name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.categoryName),
                onChanged: (v) => _name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.selectColor),
              ),
              // カラー選択。既存の色があれば選択状態にする
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final c in _colors)
                      GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == c ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 保存ボタンをタップしたときにカテゴリ名を更新
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _save();
                  }
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
