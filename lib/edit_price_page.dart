import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'domain/entities/price_info.dart';
import 'presentation/viewmodels/edit_price_viewmodel.dart';
import 'util/input_validators.dart';
import 'util/unit_localization.dart';
import 'add_inventory_page.dart';
import 'widgets/inventory_dropdown.dart';

/// セール情報編集画面
class EditPricePage extends StatefulWidget {
  final PriceInfo info;
  const EditPricePage({super.key, required this.info});

  @override
  State<EditPricePage> createState() => _EditPricePageState();
}

class _EditPricePageState extends State<EditPricePage> {
  /// 画面状態を管理する ViewModel
  late final EditPriceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditPriceViewModel(widget.info)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// 編集画面のウィジェットツリーを組み立てる
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.priceEditTitle)),
      body: !_viewModel.loaded
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.inventories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(loc.noItems),
                      const SizedBox(height: 8),
                      // 商品が未登録の場合に開く追加ボタン
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddInventoryPage()),
                          );
                        },
                        child: Text(loc.addItem),
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
                          label: loc.itemName,
                          inventories: _viewModel.inventories,
                          value: _viewModel.inventory,
                          onChanged: (v) => setState(() => _viewModel.inventory = v),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          title: Text(loc.expiry('${_viewModel.expiry.year}/${_viewModel.expiry.month}/${_viewModel.expiry.day}')),
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
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.count),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _viewModel.count.toString(),
                          onChanged: (v) => setState(() => _viewModel.count = double.tryParse(v) ?? 1),
                          validator: (v) => positiveNumberValidator(context, v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.volume),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _viewModel.volume.toString(),
                          onChanged: (v) => setState(() => _viewModel.volume = double.tryParse(v) ?? 1),
                          validator: (v) => positiveNumberValidator(context, v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.regularPrice),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _viewModel.regularPrice.toString(),
                          onChanged: (v) => setState(() => _viewModel.regularPrice = double.tryParse(v) ?? 0),
                          validator: (v) => nonNegativeNumberValidator(context, v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.salePrice),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          initialValue: _viewModel.salePrice.toString(),
                          onChanged: (v) => setState(() => _viewModel.salePrice = double.tryParse(v) ?? 0),
                          validator: (v) => nonNegativeNumberValidator(context, v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.shop),
                          initialValue: _viewModel.shop,
                          onChanged: (v) => _viewModel.shop = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.approvalUrl),
                          initialValue: _viewModel.approvalUrl,
                          onChanged: (v) => _viewModel.approvalUrl = v,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: loc.memoOptional),
                          initialValue: _viewModel.memo,
                          onChanged: (v) => _viewModel.memo = v,
                        ),
                        const SizedBox(height: 12),
                        // 合計容量を単位→値の順で表示
                        Text(
                          loc.totalVolume(
                            localizeUnit(
                                context, _viewModel.inventory?.unit ?? ''),
                            _viewModel.totalVolume.toStringAsFixed(2),
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          loc.unitPrice(_viewModel.unitPrice.toStringAsFixed(2)),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 24),
                        // 入力内容を保存するボタン
                        ElevatedButton(
                          onPressed: () async {
                            if (_viewModel.formKey.currentState!.validate()) {
                              try {
                                await _viewModel.save();
                                if (!mounted) return;
                                await ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(loc.saved)))
                                    .closed;
                                if (mounted) Navigator.pop(context);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(loc.saveFailed)));
                                }
                              }
                            }
                          },
                          child: Text(loc.save),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
