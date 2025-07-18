import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/category.dart';
import 'add_category_page.dart';
import 'presentation/viewmodels/edit_inventory_viewmodel.dart';
import 'util/unit_localization.dart';
import 'util/item_type_localization.dart';
import 'widgets/inventory_form.dart';
import 'widgets/empty_state.dart';

/// 商品を編集する画面のウィジェット
class EditInventoryPage extends StatefulWidget {
  final String id;
  final String itemName;
  final Category category;
  final String itemType;
  final double quantity;
  final double volume;
  final String unit;
  final String note;
  // テスト用に初期カテゴリを差し込めるようにする
  final List<Category>? categories;

  const EditInventoryPage({
    super.key,
    required this.id,
    required this.itemName,
    required this.category,
    required this.itemType,
    required this.quantity,
    required this.volume,
    required this.unit,
    required this.note,
    this.categories,
  });

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  /// 画面状態を管理する ViewModel
  late final EditInventoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditInventoryViewModel()
      ..load(
        id: widget.id,
        itemName: widget.itemName,
        category: widget.category,
        itemType: widget.itemType,
        quantity: widget.quantity,
        volume: widget.volume,
        unit: widget.unit,
        note: widget.note,
        // テストから渡されたカテゴリ一覧を利用
        initialCategories: widget.categories,
      );
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  /// 保存ボタンを押したときの処理
  Future<void> _saveItem() async {
    await _viewModel.save();
  }

  @override
  void dispose() {
    _viewModel.disposeSubscriptions();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // カテゴリがまだ読み込まれていない場合はローディング
    if (!_viewModel.categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリが存在しない場合は追加を促す画面を表示
    if (_viewModel.categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
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
    // 商品編集フォームを表示
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InventoryForm(
          viewModel: _viewModel,
          includeQuantity: false,
          onSave: () async {
            if (_viewModel.formKey.currentState!.validate()) {
              await _saveItem();
              if (mounted) Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
