import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'presentation/viewmodels/price_detail_viewmodel.dart';
import "domain/entities/price_info.dart";
import 'util/unit_localization.dart';
import 'edit_price_page.dart';

/// セール詳細情報表示画面
class PriceDetailPage extends StatelessWidget {
  final PriceDetailViewModel viewModel;
  PriceDetailPage({super.key, required PriceInfo info}) : viewModel = PriceDetailViewModel(info);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final info = viewModel.info;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18);
    return Scaffold(
      appBar: AppBar(
        title: Text(info.itemName.isNotEmpty ? info.itemName : info.itemType),
        actions: [
          // セール情報編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPricePage(info: viewModel.info),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRow(loc.category, info.category),
          _buildRow(loc.itemType, info.itemType),
          _buildRow(loc.itemName, info.itemName),
          _buildRow(loc.checkedDate(_formatDate(info.checkedAt)), ''),
          _buildRow(loc.expiry(_formatDate(info.expiry)), ''),
          // 数量は単位を付けずに表示
          _buildRow(
            loc.count,
            info.count.toString(),
          ),
          // 総容量は単位付きで表示
          _buildRow(loc.totalVolumeLabel,
              '${info.totalVolume.toString()}${localizeUnit(context, info.unit)}'),
          _buildRow(loc.regularPrice, info.regularPrice.toString()),
          _buildRow(loc.salePrice, info.salePrice.toString()),
          _buildRow(loc.unitPriceLabel, info.unitPrice.toStringAsFixed(2)),
          _buildRow(loc.shop, info.shop),
          if (info.approvalUrl.isNotEmpty)
            _buildRow(loc.approvalUrl, info.approvalUrl, textStyle),
          if (info.memo.isNotEmpty) _buildRow(loc.memo, info.memo, textStyle),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  Widget _buildRow(String label, String value, [TextStyle? style]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: style ?? const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
