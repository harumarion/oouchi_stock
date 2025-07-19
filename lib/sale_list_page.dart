import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'presentation/viewmodels/sale_list_viewmodel.dart';
import 'util/localization_extensions.dart';
import 'widgets/sale_item_card.dart';

/// 買い得リスト画面
class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  late final SaleListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SaleListViewModel()..addListener(() { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final sorted = _viewModel.sortedItems;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.saleListTitle()),
        actions: [
          // 通知アイコンのトグルボタン。タップでオン/オフを切り替える
          IconButton(
            tooltip: loc.saleNotify(),
            isSelected: _viewModel.notify,
            selectedIcon: const Icon(Icons.notifications),
            icon: const Icon(Icons.notifications_none),
            onPressed: () =>
                _viewModel.updateNotify(!_viewModel.notify),
          ),
          // 並び替えメニューを開くポップアップボタン
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _viewModel.updateSort,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'end', child: Text(loc.sortEndDate())),
              PopupMenuItem(value: 'discount', child: Text(loc.sortDiscount())),
              PopupMenuItem(value: 'unit', child: Text(loc.sortUnitPrice)),
              PopupMenuItem(value: 'recommend', child: Text(loc.sortRecommend())),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final item = sorted[index];
                return SaleItemCard(
                  item: item,
                  // カードの「買い物リストに追加」ボタン押下時の処理を指定
                  onAdd: _viewModel.addToBuyList,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
