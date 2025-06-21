import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'domain/entities/price_info.dart';

/// セール詳細情報表示画面
class PriceDetailPage extends StatelessWidget {
  /// 表示するセール情報
  final PriceInfo info;

  const PriceDetailPage({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18);
    return Scaffold(
      // タイトルには商品名があれば商品名、なければ品種名を使用
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

  /// 日付を yyyy/MM/dd 形式で返す
  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  /// 項目名と値を左右に表示する行を生成
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
