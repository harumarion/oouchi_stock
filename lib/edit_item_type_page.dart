import 'package:flutter/material.dart';
import 'domain/entities/item_type.dart';
import 'domain/entities/category.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'presentation/viewmodels/edit_item_type_viewmodel.dart';

/// アイテム種別を編集する画面

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
  /// 画面状態を管理する ViewModel
  late final EditItemTypeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditItemTypeViewModel(
      widget.itemType,
      widget.categories,
    );
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _save() async {
    try {
      await _viewModel.save();
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.itemTypeEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _viewModel.name,
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
              // 保存ボタンをタップしたときにアイテム種別を更新
              ElevatedButton(
                onPressed: () {
                  if (_viewModel.formKey.currentState!.validate()) {
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
