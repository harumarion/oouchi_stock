import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'util/firestore_refs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'presentation/viewmodels/edit_category_viewmodel.dart';

import 'domain/entities/category.dart';

/// カテゴリ名を編集する画面。
class EditCategoryPage extends StatefulWidget {
  final Category category;
  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  /// 画面状態を管理する ViewModel
  late final EditCategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditCategoryViewModel(widget.category);
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _viewModel.name,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.categoryName),
                onChanged: (v) => _viewModel.name = v,
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
                    for (final c in _viewModel.colors)
                      GestureDetector(
                        onTap: () => setState(() => _viewModel.color = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _viewModel.color == c ? Colors.black : Colors.transparent,
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
                  if (_viewModel.formKey.currentState!.validate()) {
                    () async {
                      try {
                        await _viewModel.save();
                        if (!mounted) return;
                        await ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)))
                            .closed;
                        if (mounted) Navigator.pop(context, _viewModel.name);
                      } catch (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)));
                        }
                      }
                    }();
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
