import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'presentation/viewmodels/add_category_viewmodel.dart';

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
              // カラー選択エリア。タップすると色を選択できる
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
