import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'presentation/viewmodels/price_history_viewmodel.dart';
import 'domain/usecases/watch_price_by_type.dart';
import 'domain/usecases/delete_price_info.dart';

/// セール情報履歴画面
class PriceHistoryPage extends StatefulWidget {
  /// カテゴリ名
  final String category;
  /// 品種名
  final String itemType;
  /// 画面タイトルに表示する商品名
  final String? itemName;
  /// セール情報を監視するユースケース
  final WatchPriceByType? watch;
  /// セール情報を削除するユースケース
  final DeletePriceInfo? deleter;
  const PriceHistoryPage({
    super.key,
    required this.category,
    required this.itemType,
    this.itemName,
    this.watch,
    this.deleter,
  });

  @override
  State<PriceHistoryPage> createState() => _PriceHistoryPageState();
}

class _PriceHistoryPageState extends State<PriceHistoryPage> {
  /// 画面の状態を管理する ViewModel
  late final PriceHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PriceHistoryViewModel(
      category: widget.category,
      itemType: widget.itemType,
      watch: widget.watch,
      deleter: widget.deleter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18);
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemName ?? widget.itemType)),
      body: StreamBuilder<List<PriceInfo>>(
        stream: _viewModel.stream(),
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
                    // セール情報カードを長押ししたときに削除メニューを表示
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
                        // 選択した履歴を削除
                        await _viewModel.delete(p.id);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildRow(loc.category, p.category, textStyle),
                          _buildRow(loc.itemType, p.itemType, textStyle),
                          _buildRow(loc.itemName, p.itemName, textStyle),
                          _buildRow(loc.checkedDate(_formatDate(p.checkedAt)), ''),
                          _buildRow(loc.expiry(_formatDate(p.expiry)), ''),
                          _buildRow(loc.count, '${p.count} ${p.unit}'),
                          _buildRow(loc.volume, p.volume.toString()),
                          _buildRow(loc.totalVolumeLabel, p.totalVolume.toString()),
                          _buildRow(loc.regularPrice, p.regularPrice.toString()),
                          _buildRow(loc.salePrice, p.salePrice.toString()),
                          _buildRow(loc.unitPriceLabel, p.unitPrice.toStringAsFixed(2)),
                          _buildRow(loc.shop, p.shop),
                          if (p.approvalUrl.isNotEmpty)
                            _buildRow(loc.approvalUrl, p.approvalUrl, textStyle),
                          if (p.memo.isNotEmpty) _buildRow(loc.memo, p.memo, textStyle),
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

  /// 日付を YYYY/M/D 形式の文字列に変換
  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  /// ラベルと値を横並びで表示する行ウィジェットを作成
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
