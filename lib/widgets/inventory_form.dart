import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../domain/entities/category.dart';
import '../presentation/viewmodels/inventory_form_viewmodel.dart';
import '../util/unit_localization.dart';
import '../util/item_type_localization.dart';
import '../util/input_validators.dart';
import 'numeric_keyboard.dart';

/// 商品登録・編集共通の入力フォームウィジェット
/// 画面名: 在庫追加・編集ページ
class InventoryForm extends StatelessWidget {
  final InventoryFormViewModel viewModel;
  final bool includeQuantity;
  final VoidCallback onSave;
  final double quantity;
  final void Function(double delta)? onQuantityChanged;
  const InventoryForm({
    super.key,
    required this.viewModel,
    required this.onSave,
    this.includeQuantity = false,
    this.quantity = 0,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Form(
      key: viewModel.formKey,
      child: ListView(
        children: [
          TextFormField(
            initialValue: viewModel.itemName,
            decoration: InputDecoration(labelText: loc.itemName),
            onChanged: viewModel.setItemName,
            validator: (v) =>
                v == null || v.isEmpty ? loc.itemNameRequired : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Category>(
            decoration: InputDecoration(labelText: loc.category),
            value: viewModel.category,
            items: viewModel.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              if (v != null) viewModel.changeCategory(v);
            },
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final itemTypes =
                viewModel.typesMap[viewModel.category?.name] ?? [viewModel.itemType];
            if (!itemTypes.contains(viewModel.itemType)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.changeItemType(itemTypes.first);
              });
            }
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: loc.itemType),
              value: itemTypes.contains(viewModel.itemType)
                  ? viewModel.itemType
                  : null,
              items: itemTypes
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(localizeItemType(context, t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) viewModel.changeItemType(v);
              },
            );
          }),
          const SizedBox(height: 12),
          if (includeQuantity)
            Row(
              children: [
                Text('${loc.pieceCount}:'),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => onQuantityChanged?.call(-1),
                ),
                Text(quantity.toStringAsFixed(0)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onQuantityChanged?.call(1),
                ),
              ],
            ),
          if (includeQuantity) const SizedBox(height: 12),
          // 容量入力欄。フォーカス時に数値キーパッドを表示する
          NumericTextFormField(
            label: loc.volume,
            initial: viewModel.volume.toString(),
            onChanged: viewModel.setVolume,
            validator: (v) => positiveNumberValidator(context, v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: loc.unit),
            value: viewModel.unit,
            items: viewModel.units
                .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(localizeUnit(context, u)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) viewModel.setUnit(v);
            },
          ),
          const SizedBox(height: 12),
          if (includeQuantity)
            Text(
              loc.totalVolume(
                localizeUnit(context, viewModel.unit),
                (quantity * viewModel.volume).toStringAsFixed(2),
              ),
              style: const TextStyle(fontSize: 20),
            ),
          if (includeQuantity) const SizedBox(height: 12),
          TextFormField(
            initialValue: viewModel.note,
            decoration: InputDecoration(labelText: loc.memoOptional),
            onChanged: viewModel.setNote,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(loc.save),
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
