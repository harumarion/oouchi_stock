import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/add_price_info.dart';
import 'domain/usecases/fetch_all_inventory.dart';
import 'util/input_validators.dart';
import 'add_inventory_page.dart';

// セール情報追加画面

class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  // フォームの状態キー
  final _formKey = GlobalKey<FormState>();
  // 選択中の在庫
  // 選択した在庫データ
  Inventory? _inventory;
  // 取得した在庫一覧
  List<Inventory> _inventories = [];
  // 在庫一覧が読み込まれたか
  bool _loaded = false;

  // 購入数
  double _count = 1;
  // 1個あたり容量
  double _volume = 1;
  // 通常価格
  double _regularPrice = 0;
  // セール価格
  double _salePrice = 0;
  // 購入店舗
  String _shop = '';
  // 承認ページURL
  String _approvalUrl = '';
  // メモ
  String _memo = '';

  // セールの終了日
  DateTime _expiry = DateTime.now();

  final AddPriceInfo _usecase = AddPriceInfo(PriceRepositoryImpl());

  @override
  void initState() {
    super.initState();
    // 初期表示時にセール終了日のデフォルトを設定
    _expiry = DateTime.now().add(const Duration(days: 7));
    final repo = InventoryRepositoryImpl();
    // 在庫一覧を一度だけ取得
    FetchAllInventory(repo)().then((list) {
      setState(() {
        _inventories = list;
        if (list.isNotEmpty) _inventory = list.first;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 入力された数量と容量から合計容量を計算
  double get _totalVolume => _count * _volume;
  // 単価はセール価格から計算
  double get _unitPrice => _totalVolume == 0 ? 0 : _salePrice / _totalVolume;

  // 保存ボタンを押したときに呼び出される処理
  Future<void> _save() async {
    if (_inventory == null) return;
    final info = PriceInfo(
      id: '',
      inventoryId: _inventory!.id,
      // 保存時刻を確認日として登録
      checkedAt: DateTime.now(),
      category: _inventory!.category,
      itemType: _inventory!.itemType,
      itemName: _inventory!.itemName,
      count: _count,
      unit: _inventory!.unit,
      volume: _volume,
      totalVolume: _totalVolume,
      regularPrice: _regularPrice,
      salePrice: _salePrice,
      shop: _shop,
      approvalUrl: _approvalUrl,
      memo: _memo,
      unitPrice: _unitPrice,
      expiry: _expiry,
    );
    await _usecase(info);
  }

  // 画面のウィジェットツリーを組み立てる
  // ユーザーが入力値を変更するたびに計算結果を表示
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.priceAddTitle)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _inventories.isEmpty
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
                      title: Text(AppLocalizations.of(context)!.expiry('${_expiry.year}/${_expiry.month}/${_expiry.day}')),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: _expiry,
                        );
                        if (picked != null) setState(() => _expiry = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.count),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: '1',
                      onChanged: (v) => setState(() => _count = double.tryParse(v) ?? 1),
                      validator: (v) => positiveNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.volume),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      initialValue: '1',
                      onChanged: (v) => setState(() => _volume = double.tryParse(v) ?? 1),
                      validator: (v) => positiveNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.regularPrice),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() => _regularPrice = double.tryParse(v) ?? 0),
                      validator: (v) => nonNegativeNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.salePrice),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() => _salePrice = double.tryParse(v) ?? 0),
                      validator: (v) => nonNegativeNumberValidator(context, v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.shop),
                      onChanged: (v) => _shop = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.approvalUrl),
                      onChanged: (v) => _approvalUrl = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.memoOptional),
                      onChanged: (v) => _memo = v,
                    ),
                    const SizedBox(height: 12),
                    // 合計容量を大きめの文字で表示
                    Text(
                      AppLocalizations.of(context)!
                          .totalVolume(_totalVolume.toStringAsFixed(2)),
                      style: const TextStyle(fontSize: 20),
                    ),
                    // 単価を大きめの文字で表示
                    Text(
                      AppLocalizations.of(context)!
                          .unitPrice(_unitPrice.toStringAsFixed(2)),
                      style: const TextStyle(fontSize: 20),
                    ),
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
                          } catch (e) {
                            // 例外をログに出力
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
