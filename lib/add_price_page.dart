import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'presentation/viewmodels/add_price_viewmodel.dart';
import 'util/input_validators.dart';
import 'util/unit_localization.dart';
import 'widgets/inventory_dropdown.dart';
import 'widgets/numeric_keyboard.dart';
import 'add_inventory_page.dart';

// セール情報追加画面

class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  /// 画面状態を管理する ViewModel
  late final AddPriceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 初期表示時にセール終了日のデフォルトを設定
    _viewModel = AddPriceViewModel();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // 画面のウィジェットツリーを組み立てる
  // ユーザーが入力値を変更するたびに計算結果を表示
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceAddTitle)),
      body: !_viewModel.loaded
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.inventories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.noItems),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddInventoryPage()),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.addItem),
                      ),
                    ],
                  ),
                )
              : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _viewModel.formKey,
                child: ListView(
                  children: [
                    // 商品名選択ドロップダウン
                    InventoryDropdown(
                      label: AppLocalizations.of(context)!.itemName,
                      inventories: _viewModel.inventories,
                      value: _viewModel.inventory,
                      onChanged: (v) => setState(() => _viewModel.inventory = v),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.expiry('${_viewModel.expiry.year}/${_viewModel.expiry.month}/${_viewModel.expiry.day}')),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: _viewModel.expiry,
                        );
                        if (picked != null) setState(() => _viewModel.expiry = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    // 数量入力欄。キーパッドで数値を入力する
                    NumericTextFormField(
                      label: AppLocalizations.of(context)!.count,
                      initial: '0',
                      onChanged: (v) => setState(() => _viewModel.count = double.tryParse(v) ?? 0),
                      validator: (v) => positiveNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    // 容量入力欄。キーパッドで数値を入力する
                    NumericTextFormField(
                      label: AppLocalizations.of(context)!.volume,
                      initial: '0',
                      onChanged: (v) => setState(() => _viewModel.volume = double.tryParse(v) ?? 0),
                      validator: (v) => positiveNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    // 通常価格入力欄
                    NumericTextFormField(
                      label: AppLocalizations.of(context)!.regularPrice,
                      initial: '',
                      onChanged: (v) => setState(() => _viewModel.regularPrice = double.tryParse(v) ?? 0),
                      validator: (v) => nonNegativeNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    // セール価格入力欄
                    NumericTextFormField(
                      label: AppLocalizations.of(context)!.salePrice,
                      initial: '',
                      onChanged: (v) => setState(() => _viewModel.salePrice = double.tryParse(v) ?? 0),
                      validator: (v) => nonNegativeNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.shop),
                      onChanged: (v) => _viewModel.shop = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.approvalUrl),
                      onChanged: (v) => _viewModel.approvalUrl = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memoOptional),
                      onChanged: (v) => _viewModel.memo = v,
                    ),
                    const SizedBox(height: 12),
                      // セール情報追加画面: 合計容量を値の後ろに単位を付けて表示
                      Text(
                        AppLocalizations.of(context)!.totalVolume(
                          localizeUnit(
                              context, _viewModel.inventory?.unit ?? ''),
                          _viewModel.totalVolume.toStringAsFixed(2),
                        ),
                        style: const TextStyle(fontSize: 20),
                      ),
                    // 単価を大きめの文字で表示
                    Text(
                      AppLocalizations.of(context)!
                          .unitPrice(_viewModel.unitPrice.toStringAsFixed(2)),
                      style: const TextStyle(fontSize: 20),
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
                            debugPrint('セール情報保存失敗: $e');
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
