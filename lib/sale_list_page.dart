import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';

/// セール情報1件分のデータモデル
class SaleItem {
  final String name; // 商品名
  final String shop; // 店舗名
  final double regularPrice; // 通常価格
  final double salePrice; // セール価格
  final DateTime start; // セール開始日
  final DateTime end; // セール終了日
  final int stock; // 在庫数
  final bool recommended; // おすすめフラグ
  final bool lowest; // 最安値フラグ

  SaleItem({
    required this.name,
    required this.shop,
    required this.regularPrice,
    required this.salePrice,
    required this.start,
    required this.end,
    required this.stock,
    this.recommended = false,
    this.lowest = false,
  });
}

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

  // 並び替えの種類
  String _sort = 'end';

  @override
  Widget build(BuildContext context) {
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
                  label: Text(loc.sortUnitPrice()),
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
                final daysLeft = item.end.difference(DateTime.now()).inDays;
                final expired = daysLeft <= 1;
                final period =
                    '${item.start.month}/${item.start.day}〜${item.end.month}/${item.end.day}';
                return Dismissible(
                  key: ValueKey(item.name + item.shop),
                  background: Container(color: Colors.green),
                  secondaryBackground: Container(color: Colors.red),
                  onDismissed: (_) {},
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (item.recommended)
                                const Icon(Icons.notifications_active,
                                    color: Colors.orange),
                              if (item.lowest)
                                const Icon(Icons.price_check, color: Colors.red),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(item.shop),
                          const SizedBox(height: 4),
                          Text(
                            '${loc.salePriceLabel(item.salePrice.toStringAsFixed(0))}  '
                            '${loc.regularPriceLabel(item.regularPrice.toStringAsFixed(0))}',
                          ),
                          const SizedBox(height: 4),
                          Text(loc.salePeriod(period)),
                          const SizedBox(height: 4),
                          Text(
                            loc.daysLeft(daysLeft.toString()),
                            style: TextStyle(color: expired ? Colors.red : null),
                          ),
                          const SizedBox(height: 4),
                          Text(loc.stockInfo(item.stock)),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {},
                              // 商品を買い物リストへ追加するボタン
                              child: Text(loc.addToList()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension _LocExt on AppLocalizations {
  String salePeriod(String period) => '期間: $period';
  String stockInfo(int count) => '在庫 $count個';
  String addToList() => '買い物リストに追加';
  String saleListTitle() => '買い得リスト';
  String saleNotify() => 'セール通知';
  String sortEndDate() => '終了日が近い順';
  String sortDiscount() => '割引率順';
  String sortUnitPrice() => '単価安い順';
  String sortRecommend() => 'おすすめ順';
}
