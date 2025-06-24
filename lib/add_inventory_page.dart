import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/category.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/settings_menu_button.dart';
import 'main.dart';
import 'add_category_page.dart';
import 'presentation/viewmodels/add_inventory_viewmodel.dart';

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
        child: Form(
          key: _viewModel.formKey,
          child: ListView(
            children: [
              // 商品名入力
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName),
                onChanged: (value) => _viewModel.setItemName(value),
                validator: (value) =>
                    value == null || value.isEmpty ? AppLocalizations.of(context)!.itemNameRequired : null,
              ),
              const SizedBox(height: 12),
              // カテゴリ選択
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category),
                value: _viewModel.category,
                items: _viewModel.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  _viewModel.changeCategory(value);
                },
              ),
              const SizedBox(height: 12),
              // 品種選択
              Builder(builder: (context) {
                final itemTypes =
                    _viewModel.typesMap[_viewModel.category?.name] ?? ['その他'];
                if (!itemTypes.contains(_viewModel.itemType)) {
                  _viewModel.changeItemType(itemTypes.first);
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemType),
                  value: _viewModel.itemType,
                  items: itemTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _viewModel.changeItemType(value);
                  },
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.pieceCount}:'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _viewModel.changeQuantity(-1),
                  ),
                  Text(_viewModel.quantity.toStringAsFixed(0)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _viewModel.changeQuantity(1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 1個あたり容量入力
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.volume),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: '1',
                onChanged: (v) => _viewModel.setVolume(v),
              ),
              const SizedBox(height: 12),
              // 単位選択
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.unit),
                value: _viewModel.unit,
                items: _viewModel.units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) => _viewModel.setUnit(value!),
              ),
              const SizedBox(height: 12),
              // 総容量表示
              Text(
                AppLocalizations.of(context)!.totalVolume(_viewModel.totalVolume.toStringAsFixed(2)),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              // メモの入力（任意）
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memoOptional),
                onChanged: (value) => _viewModel.setNote(value),
              ),
              const SizedBox(height: 24),
              // 入力内容を保存するボタン
              // 保存ボタン。入力が正しい場合は Firestore へ登録
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context)!.save),
                onPressed: () async {
                  // フォームの入力が正しいか確認
                  if (_viewModel.formKey.currentState!.validate()) {
                    try {
                      await _viewModel.save();
                      if (!mounted) return;
                      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
                      );
                      await snackBar.closed;
                      if (!mounted) return;
                      // 画面がスタックに積まれている場合のみ前の画面へ戻る
                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context);
                      } else {
                        // ルート画面から商品追加した場合はフォームをリセットする
                        setState(() {
                          _viewModel.formKey.currentState?.reset();
                          _viewModel.setItemName('');
                          _viewModel.setNote('');
                          _viewModel.quantity = 1.0;
                          _viewModel.volume = 1.0;
                          _viewModel.notifyListeners();
                        });
                      }
                    } on FirebaseException catch (e) {
                      // Firestore からの例外をログに出力
                      debugPrint('在庫保存失敗: ${e.message ?? e.code}');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${AppLocalizations.of(context)!.saveFailed}: ${e.message ?? e.code}'),
                          ),
                        );
                      }
                    } catch (e) {
                      // その他の例外をログに出力
                      debugPrint('在庫保存失敗: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
