import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// カテゴリを追加する画面。
/// 入力されたカテゴリ名を Firestore の `categories` コレクションに保存する。
class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';

  /// 保存ボタンの処理。入力されたカテゴリ名を保存する
  Future<void> _save() async {
    try {
      final id = Random().nextInt(0xffffffff);
      await FirebaseFirestore.instance
          .collection('categories')
          .add({'id': id, 'name': _name, 'createdAt': Timestamp.now()});
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saved)))
          .closed;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).categoryAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).categoryName),
                onChanged: (v) => _name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context).required : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _save();
                  }
                },
                child: Text(AppLocalizations.of(context).save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
