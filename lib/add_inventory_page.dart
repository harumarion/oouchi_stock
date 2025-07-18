import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/category.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/settings_menu_button.dart';
import 'main.dart';
import 'add_category_page.dart';
import 'presentation/viewmodels/add_inventory_viewmodel.dart';
import 'util/unit_localization.dart';
import 'util/item_type_localization.dart';
import 'widgets/inventory_form.dart';
import 'widgets/empty_state.dart';

// 商品を追加する画面のウィジェット

class AddInventoryPage extends StatefulWidget {
  final List<Category>? categories;
  const AddInventoryPage({super.key, this.categories});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  /// 画面の状態を管理する ViewModel
  late final AddInventoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddInventoryViewModel()..load(widget.categories);
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.disposeSubscriptions();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryAddTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_viewModel.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryAddTitle)),
        body: EmptyState(
          message: AppLocalizations.of(context)!.noCategories,
          buttonLabel: AppLocalizations.of(context)!.addCategory,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCategoryPage()),
            );
          },
        ),
      );
    }
    // 画面のレイアウトを構築
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventoryAddTitle),
        actions: [
          // 設定メニュー。買い物リスト画面と同じ内容を表示
          SettingsMenuButton(
            categories: _viewModel.categories,
            onCategoriesChanged: (l) => setState(() => _viewModel.categories = List.from(l)),
            onLocaleChanged: (l) =>
                context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
            onConditionChanged: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InventoryForm(
          viewModel: _viewModel,
          includeQuantity: true,
          quantity: _viewModel.quantity,
          onQuantityChanged: _viewModel.changeQuantity,
          onSave: () async {
            if (_viewModel.formKey.currentState!.validate()) {
              final ctx = context;
              try {
                await _viewModel.save();
                if (!ctx.mounted) return;
                final snackBar = ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(ctx)!.saved)),
                );
                await snackBar.closed;
                if (!ctx.mounted) return;
                if (Navigator.of(ctx).canPop()) {
                  Navigator.pop(ctx);
                } else {
                  setState(() {
                    _viewModel.formKey.currentState?.reset();
                    _viewModel.resetFields();
                  });
                }
              } on FirebaseException catch (e) {
                debugPrint('在庫保存失敗: ${e.message ?? e.code}');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${AppLocalizations.of(ctx)!.saveFailed}: ${e.message ?? e.code}'),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('在庫保存失敗: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(ctx)!.saveFailed)),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}
