import 'package:flutter/material.dart';
import 'presentation/viewmodels/add_item_type_viewmodel.dart';

import 'domain/entities/category.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

class AddItemTypePage extends StatefulWidget {
  final List<Category> categories;
  const AddItemTypePage({super.key, required this.categories});

  @override
  State<AddItemTypePage> createState() => _AddItemTypePageState();
}

class _AddItemTypePageState extends State<AddItemTypePage> {
  /// 画面状態を管理する ViewModel
  late final AddItemTypeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddItemTypeViewModel(widget.categories);
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemTypeAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemType),
                onChanged: (v) => _viewModel.name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                value: _viewModel.category,
                items: _viewModel.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _viewModel.category = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_viewModel.formKey.currentState!.validate()) {
                    try {
                      await _viewModel.save();
                      if (!mounted) return;
                      await ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)))
                          .closed;
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint('品種保存失敗: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)));
                      }
                    }
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
