import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/delete_price_info.dart';
import 'domain/usecases/watch_price_by_type.dart';

// セール情報履歴画面

class PriceHistoryPage extends StatelessWidget {
  /// カテゴリ名
  final String category;
  /// 品種名
  final String itemType;
  /// セール情報取得ユースケース
  final WatchPriceByType _watch;
  /// セール情報削除ユースケース
  final DeletePriceInfo _deleter;

  /// テスト時にユースケースを差し替えられるようにしている
  PriceHistoryPage({
    super.key,
    required this.category,
    required this.itemType,
    WatchPriceByType? watch,
    DeletePriceInfo? deleter,
  })  : _watch = watch ?? WatchPriceByType(PriceRepositoryImpl()),
        _deleter = deleter ?? DeletePriceInfo(PriceRepositoryImpl());

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18);
    return Scaffold(
      appBar: AppBar(title: Text(itemType)),
      body: StreamBuilder<List<PriceInfo>>(
        stream: _watch(category, itemType),
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
                        await _deleter(p.id);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildRow(loc.itemName, p.itemName, textStyle),
                          _buildRow(loc.checkedDate(_formatDate(p.checkedAt)), '', textStyle),
                          _buildRow(loc.count, '${p.count} ${p.unit}', textStyle),
                          _buildRow(loc.volume, p.volume.toString(), textStyle),
                          _buildRow(loc.totalVolumeLabel, p.totalVolume.toString(), textStyle),
                          _buildRow(loc.regularPrice, p.regularPrice.toString(), textStyle),
                          _buildRow(loc.salePrice, p.salePrice.toString(), textStyle),
                          _buildRow(loc.unitPriceLabel, p.unitPrice.toStringAsFixed(2), textStyle),
                          _buildRow(loc.shop, p.shop, textStyle),
                          if (p.approvalUrl.isNotEmpty)
                            _buildRow(loc.approvalUrl, p.approvalUrl, textStyle),
                          if (p.memo.isNotEmpty)
                            _buildRow(loc.memo, p.memo, textStyle),
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
  Widget _buildRow(String label, String value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: style,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
