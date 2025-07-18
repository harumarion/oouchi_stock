import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'presentation/viewmodels/add_category_viewmodel.dart';
import 'widgets/color_picker.dart';

/// カテゴリを追加する画面。
/// 入力されたカテゴリ名を Firestore の `categories` コレクションに保存する。
class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  /// 画面状態を管理する ViewModel
  late final AddCategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddCategoryViewModel();
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.categoryAddTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.categoryName),
                onChanged: (v) => _viewModel.name = v,
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context)!.selectColor),
              ),
              // 共通ウィジェットで色を選択
              ColorPicker(
                colors: _viewModel.colors,
                selected: _viewModel.color,
                onSelected: (c) => setState(() => _viewModel.color = c),
              ),
              const SizedBox(height: 24),
              // 保存ボタンをタップしたときの処理
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
                      debugPrint('カテゴリ保存失敗: $e');
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
