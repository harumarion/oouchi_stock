import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/price_info.dart';
import 'presentation/viewmodels/price_history_viewmodel.dart';
import 'domain/usecases/watch_price_by_type.dart';
import 'domain/usecases/delete_price_info.dart';
// 数量や容量の単位をユーザーの言語設定に合わせて表示する
import 'util/unit_localization.dart';

/// セール情報履歴画面
class PriceHistoryPage extends StatefulWidget {
  /// 表示するカテゴリ名
  final String category;
  /// 表示する品種名
  final String itemType;
  /// 任意の商品名。指定がない場合は品種名をタイトルに使用
  final String? itemName;
  /// Firestore 監視ユースケース（テスト用）
  final WatchPriceByType? watch;
  /// 削除ユースケース（テスト用）
  final DeletePriceInfo? deleter;
  /// 外部から注入する ViewModel（テスト用）
  final PriceHistoryViewModel? viewModel;

  const PriceHistoryPage({
    super.key,
    required this.category,
    required this.itemType,
    this.itemName,
    this.watch,
    this.deleter,
    this.viewModel,
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
    // 指定があれば外部提供の ViewModel を利用し、なければ新規作成
    _viewModel = widget.viewModel ??
        PriceHistoryViewModel(
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
                Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) async {
                    final res = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(loc.deleteConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(loc.delete),
                          ),
                        ],
                      ),
                    );
                    return res ?? false;
                  },
                  onDismissed: (_) async => _viewModel.delete(p.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildRow(loc.category, p.category, textStyle),
                          _buildRow(loc.itemType, p.itemType, textStyle),
                          _buildRow(loc.itemName, p.itemName, textStyle),
                          _buildRow(loc.checkedDate(_formatDate(p.checkedAt)), ''),
                          _buildRow(loc.expiry(_formatDate(p.expiry)), ''),
                          // 数量は単位を付けずに表示
                          _buildRow(loc.count, p.count.toString()),
                          // 1個あたり容量を単位付きで表示
                          _buildRow(loc.volume,
                              '${p.volume.toString()}${localizeUnit(context, p.unit)}'),
                          // 総容量を単位付きで表示
                          _buildRow(loc.totalVolumeLabel,
                              '${p.totalVolume.toString()}${localizeUnit(context, p.unit)}'),
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

  /// 日付を YYYY/M/D 形式に整形
  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  /// ラベルと値を左右に並べて表示する共通行ウィジェット
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
