import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// カテゴリ名を編集する画面。
class EditCategoryPage extends StatefulWidget {
  final String initialName;
  const EditCategoryPage({super.key, required this.initialName});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
  }

  Future<void> _save() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: widget.initialName)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({'name': _name});
      }
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('保存しました')))
          .closed;
      if (mounted) Navigator.pop(context, _name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
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
