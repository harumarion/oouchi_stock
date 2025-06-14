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

  /// カテゴリを保存する処理。失敗時は SnackBar で通知する。
  Future<void> _save() async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .add({'name': _name, 'createdAt': Timestamp.now()});
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('保存しました')))
          .closed;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'カテゴリ名'),
                onChanged: (v) => _name = v,
                validator: (v) => v == null || v.isEmpty ? '必須項目です' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _save();
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
