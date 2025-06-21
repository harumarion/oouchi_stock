import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'data/repositories/buy_list_repository_impl.dart';
import 'domain/entities/buy_item.dart';
import 'domain/usecases/add_buy_item.dart';
import 'models/sale_item.dart';
import 'util/localization_extensions.dart';
import 'widgets/sale_item_card.dart';

/// 買い得リスト画面
class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  // サンプルデータ
  final List<SaleItem> _items = [
    SaleItem(
      name: 'コーヒー豆 200g',
      shop: 'Amazon',
      regularPrice: 1200,
      salePrice: 980,
      start: DateTime.now().subtract(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 2)),
      stock: 5,
      recommended: true,
      lowest: true,
    ),
    SaleItem(
      name: 'トイレットペーパー 12ロール',
      shop: '楽天',
      regularPrice: 600,
      salePrice: 480,
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 5)),
      stock: 20,
    ),
    SaleItem(
      name: '洗剤 詰め替え用',
      shop: '近所のスーパー',
      regularPrice: 350,
      salePrice: 300,
      start: DateTime.now().subtract(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 1)),
      stock: 1,
    ),
  ];

  bool _notify = true; // 通知設定

  // 並び替え方法。"end"=終了日近い順、"discount"=割引率順、
  // "unit"=単価安い順、"recommend"=おすすめ順
  String _sort = 'end';

  // 買い物リストへ追加するユースケース
  final AddBuyItem _addBuyItem = AddBuyItem(BuyListRepositoryImpl());

  @override
  Widget build(BuildContext context) {
    // 買い得リスト画面のビルド。並び替えや通知設定の状態を反映する
    final loc = AppLocalizations.of(context)!;
    // 並び替え
    final sorted = List<SaleItem>.from(_items);
    sorted.sort((a, b) {
      if (_sort == 'discount') {
        final ad = (a.regularPrice - a.salePrice) / a.regularPrice;
        final bd = (b.regularPrice - b.salePrice) / b.regularPrice;
        return bd.compareTo(ad);
      } else if (_sort == 'unit') {
        final au = a.salePrice;
        final bu = b.salePrice;
        return au.compareTo(bu);
      } else if (_sort == 'recommend') {
        if (a.recommended == b.recommended) return 0;
        return a.recommended ? -1 : 1;
      }
      return a.end.compareTo(b.end);
    });

    return Scaffold(
      appBar: AppBar(
        // 画面タイトル
        title: Text(loc.saleListTitle()),
        actions: [
          Row(
            children: [
              // セール通知設定スイッチのラベル
              Text(loc.saleNotify()),
              Switch(
                value: _notify,
                onChanged: (v) => setState(() => _notify = v),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  // セール終了日が近い順に並び替え
                  label: Text(loc.sortEndDate()),
                  selected: _sort == 'end',
                  onSelected: (_) => setState(() => _sort = 'end'),
                ),
                ChoiceChip(
                  // 割引率の高い順に並び替え
                  label: Text(loc.sortDiscount()),
                  selected: _sort == 'discount',
                  onSelected: (_) => setState(() => _sort = 'discount'),
                ),
                ChoiceChip(
                  // 単価が安い順に並び替え
                  label: Text(loc.sortUnitPrice),
                  selected: _sort == 'unit',
                  onSelected: (_) => setState(() => _sort = 'unit'),
                ),
                ChoiceChip(
                  // おすすめ度順に並び替え
                  label: Text(loc.sortRecommend()),
                  selected: _sort == 'recommend',
                  onSelected: (_) => setState(() => _sort = 'recommend'),
                ),
              ],
            ),
          ),
          Expanded(
            // セール情報をリスト表示
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final item = sorted[index];
                return SaleItemCard(
                  item: item,
                  addUsecase: _addBuyItem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
