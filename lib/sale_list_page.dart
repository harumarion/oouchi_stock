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
          Row(
            children: [
              Text(loc.saleNotify()),
              Switch(
                value: _viewModel.notify,
                onChanged: (v) => _viewModel.updateNotify(v),
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
                  label: Text(loc.sortEndDate()),
                  selected: _viewModel.sort == 'end',
                  onSelected: (_) => _viewModel.updateSort('end'),
                ),
                ChoiceChip(
                  label: Text(loc.sortDiscount()),
                  selected: _viewModel.sort == 'discount',
                  onSelected: (_) => _viewModel.updateSort('discount'),
                ),
                ChoiceChip(
                  label: Text(loc.sortUnitPrice),
                  selected: _viewModel.sort == 'unit',
                  onSelected: (_) => _viewModel.updateSort('unit'),
                ),
                ChoiceChip(
                  label: Text(loc.sortRecommend()),
                  selected: _viewModel.sort == 'recommend',
                  onSelected: (_) => _viewModel.updateSort('recommend'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final item = sorted[index];
                return SaleItemCard(
                  item: item,
                  addUsecase: _viewModel.addBuyItem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
