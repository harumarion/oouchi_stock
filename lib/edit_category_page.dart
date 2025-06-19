import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';

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

  @override
  void initState() {
    super.initState();
    _name = widget.category.name;
  }

  /// 保存ボタンの処理
  Future<void> _save() async {
    try {
      final snapshot = await userCollection('categories')
          .where('id', isEqualTo: widget.category.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.update({'name': _name});
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
              const SizedBox(height: 24),
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
