import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/add_price_info.dart';
import 'domain/usecases/fetch_all_inventory.dart';

// セール情報追加画面

class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _checkedAt = DateTime.now();
  Inventory? _inventory;
  List<Inventory> _inventories = [];

  double _count = 1;
  double _volume = 1;
  double _price = 0;
  String _shop = '';

  final AddPriceInfo _usecase = AddPriceInfo(PriceRepositoryImpl());

  @override
  void initState() {
    super.initState();
    final repo = InventoryRepositoryImpl();
    // fetch all inventories once
    FetchAllInventory(repo)().then((list) {
      setState(() {
        _inventories = list;
        if (list.isNotEmpty) _inventory = list.first;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  double get _totalVolume => _count * _volume;
  double get _unitPrice => _totalVolume == 0 ? 0 : _price / _totalVolume;

  Future<void> _save() async {
    if (_inventory == null) return;
    final info = PriceInfo(
      id: '',
      inventoryId: _inventory!.id,
      checkedAt: _checkedAt,
      category: _inventory!.category,
      itemType: _inventory!.itemType,
      itemName: _inventory!.itemName,
      count: _count,
      unit: _inventory!.unit,
      volume: _volume,
      totalVolume: _totalVolume,
      price: _price,
      shop: _shop,
      unitPrice: _unitPrice,
    );
    await _usecase(info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceAddTitle)),
      body: _inventories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Inventory>(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName),
                      value: _inventory,
                      items: _inventories
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text('${e.itemType} / ${e.itemName}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _inventory = v),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.checkedDate('${_checkedAt.year}/${_checkedAt.month}/${_checkedAt.day}')),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: _checkedAt,
                        );
                        if (picked != null) setState(() => _checkedAt = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.count),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: '1',
                      onChanged: (v) => setState(() => _count = double.tryParse(v) ?? 1),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.volume),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: '1',
                      onChanged: (v) => setState(() => _volume = double.tryParse(v) ?? 1),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.price),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() => _price = double.tryParse(v) ?? 0),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.shop),
                      onChanged: (v) => _shop = v,
                    ),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.totalVolume(_totalVolume.toStringAsFixed(2))),
                    Text(AppLocalizations.of(context)!.unitPrice(_unitPrice.toStringAsFixed(2))),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await _save();
                            if (!mounted) return;
                            await ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)))
                                .closed;
                            if (mounted) Navigator.pop(context);
                          } catch (_) {
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
