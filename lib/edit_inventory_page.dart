import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/category.dart';
import 'add_category_page.dart';
import 'presentation/viewmodels/edit_inventory_viewmodel.dart';
import 'util/unit_localization.dart';

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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.noCategories),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCategory),
              ),
            ],
          ),
        ),
      );
    }
    // 商品編集フォームを表示
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventoryEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _viewModel.formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _viewModel.itemName,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName),
                onChanged: (v) => _viewModel.setItemName(v),
                validator: (v) =>
                    v == null || v.isEmpty ? AppLocalizations.of(context)!.itemNameRequired : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                value: _viewModel.category,
                items: _viewModel.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _viewModel.changeCategory(v);
                  });
                },
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                // 選択中カテゴリに該当する品種リストを取得
                final itemTypes =
                    _viewModel.typesMap[_viewModel.category?.name] ?? ['その他'];
                // 品種リストに現在の値が無ければ自動的に先頭に切り替える
                final selectedType = itemTypes.contains(_viewModel.itemType)
                    ? _viewModel.itemType
                    : itemTypes.first;
                if (selectedType != _viewModel.itemType) {
                  // ビルド完了後に状態を更新する
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _viewModel.changeItemType(selectedType);
                  });
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.itemType),
                  value:
                      itemTypes.contains(_viewModel.itemType) ? _viewModel.itemType : null,
                  items: itemTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _viewModel.changeItemType(v));
                  },
                );
              }),
              const SizedBox(height: 12),
              // 1個あたり容量の入力欄を追加
              TextFormField(
                initialValue: _viewModel.volume.toString(),
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.volume),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => _viewModel.setVolume(v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.unit),
                value: _viewModel.unit,
                items: _viewModel.units
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(localizeUnit(context, u)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _viewModel.setUnit(v ?? '')),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _viewModel.note,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memo),
                onChanged: (v) => _viewModel.setNote(v),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.save),
                onPressed: () async {
                  if (_viewModel.formKey.currentState!.validate()) {
                    await _saveItem();
                    if (mounted) Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
