import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';

import 'domain/entities/category.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

class AddItemTypePage extends StatefulWidget {
  final List<Category> categories;
  const AddItemTypePage({super.key, required this.categories});

  @override
  State<AddItemTypePage> createState() => _AddItemTypePageState();
}

class _AddItemTypePageState extends State<AddItemTypePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  Category? _category;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _category = widget.categories.first;
    }
  }

  Future<void> _save() async {
    try {
      final id = Random().nextInt(0xffffffff);
      await userCollection('itemTypes').add({
        'id': id,
        'category': _category?.name ?? '',
        'name': _name,
        'createdAt': Timestamp.now(),
      });
      if (!mounted) return;
      await ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)))
          .closed;
      if (mounted) Navigator.pop(context);
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemTypeAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemType),
                onChanged: (v) => _name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
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
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
