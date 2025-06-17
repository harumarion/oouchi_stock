import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'domain/entities/item_type.dart';
import 'domain/entities/category.dart';
import 'l10n/app_localizations.dart';

class EditItemTypePage extends StatefulWidget {
  final ItemType itemType;
  final List<Category> categories;
  const EditItemTypePage({
    super.key,
    required this.itemType,
    required this.categories,
  });

  @override
  State<EditItemTypePage> createState() => _EditItemTypePageState();
}

class _EditItemTypePageState extends State<EditItemTypePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  Category? _category;

  @override
  void initState() {
    super.initState();
    _name = widget.itemType.name;
    _category = widget.categories.firstWhere(
      (c) => c.name == widget.itemType.category,
      orElse: () => widget.categories.first,
    );
  }

  Future<void> _save() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('itemTypes')
          .where('id', isEqualTo: widget.itemType.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference
            .update({'name': _name, 'category': _category?.name ?? ''});
      }
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saved)))
          .closed;
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).saveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).itemTypeEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).itemType),
                onChanged: (v) => _name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context).required : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).category),
                value: _category,
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
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
