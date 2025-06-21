import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/delete_price_info.dart';
import 'domain/usecases/watch_price_by_type.dart';

// セール情報履歴画面

class PriceHistoryPage extends StatelessWidget {
  final String category;
  final String itemType;
  const PriceHistoryPage({super.key, required this.category, required this.itemType});

  @override
  Widget build(BuildContext context) {
    final watch = WatchPriceByType(PriceRepositoryImpl());
    final deleter = DeletePriceInfo(PriceRepositoryImpl());
    return Scaffold(
      appBar: AppBar(title: Text(itemType)),
      body: StreamBuilder<List<PriceInfo>>(
        stream: watch(category, itemType),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final err = snapshot.error?.toString() ?? 'unknown';
            return Center(child: Text(AppLocalizations.of(context)!.loadError(err)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          final loc = AppLocalizations.of(context)!;
          return ListView(
            children: [
              for (final p in list)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    // 長押しで削除メニューを表示
                    onLongPress: () async {
                      final res = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => SafeArea(
                          child: ListTile(
                            leading: const Icon(Icons.delete),
                            title: Text(loc.delete),
                            onTap: () => Navigator.pop(context, 'delete'),
                          ),
                        ),
                      );
                      if (res == 'delete') {
                        await deleter(p.id);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildRow(loc.itemName, p.itemName),
                          _buildRow(loc.checkedDate(_formatDate(p.checkedAt)), ''),
                          _buildRow(loc.count, '${p.count} ${p.unit}'),
                          _buildRow(loc.volume, p.volume.toString()),
                          _buildRow(loc.totalVolumeLabel, p.totalVolume.toString()),
                          _buildRow(loc.regularPrice, p.regularPrice.toString()),
                          _buildRow(loc.salePrice, p.salePrice.toString()),
                          _buildRow(loc.unitPriceLabel, p.unitPrice.toStringAsFixed(2)),
                          _buildRow(loc.shop, p.shop),
                          if (p.approvalUrl.isNotEmpty)
                            _buildRow(loc.approvalUrl, p.approvalUrl),
                          if (p.memo.isNotEmpty)
                            _buildRow(loc.memo, p.memo),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }

  /// 項目名と値を左右に表示する行を作成する
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
