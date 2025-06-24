import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'presentation/viewmodels/price_detail_viewmodel.dart';
import "domain/entities/price_info.dart";

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
      appBar: AppBar(title: Text(info.itemName.isNotEmpty ? info.itemName : info.itemType)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRow(loc.category, info.category),
          _buildRow(loc.itemType, info.itemType),
          _buildRow(loc.itemName, info.itemName),
          _buildRow(loc.checkedDate(_formatDate(info.checkedAt)), ''),
          _buildRow(loc.expiry(_formatDate(info.expiry)), ''),
          _buildRow(loc.count, '${info.count} ${info.unit}'),
          _buildRow(loc.totalVolumeLabel, info.totalVolume.toString()),
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
