import 'package:flutter/material.dart';
import 'i18n/app_localizations.dart';
import 'presentation/viewmodels/price_detail_viewmodel.dart';
import "domain/entities/price_info.dart";
import 'util/unit_localization.dart';
import 'edit_price_page.dart';

/// セール詳細情報表示画面
class PriceDetailPage extends StatefulWidget {
  /// 初期表示するセール情報
  final PriceInfo info;

  const PriceDetailPage({super.key, required this.info});

  @override
  State<PriceDetailPage> createState() => _PriceDetailPageState();
}

class _PriceDetailPageState extends State<PriceDetailPage> {
  /// 画面状態を保持する ViewModel
  late final PriceDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PriceDetailViewModel(widget.info)
      ..addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  /// 編集画面を開き、戻ってきたら情報を更新する
  Future<void> _editPrice() async {
    final updated = await Navigator.push<PriceInfo>(
      context,
      MaterialPageRoute(builder: (_) => EditPricePage(info: viewModel.info)),
    );
    if (updated != null) {
      viewModel.updateInfo(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final info = viewModel.info;
    // 詳細画面用の標準テキストスタイル
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text(info.itemName.isNotEmpty ? info.itemName : info.itemType),
        actions: [
          // セール情報編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            // 編集アイコンタップで編集画面へ遷移
            onPressed: _editPrice,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRow(context, loc.category, info.category),
          _buildRow(context, loc.itemType, info.itemType),
          _buildRow(context, loc.itemName, info.itemName),
          _buildRow(context, loc.checkedDate(_formatDate(info.checkedAt)), ''),
          _buildRow(context, loc.expiry(_formatDate(info.expiry)), ''),
          // 数量は単位を付けずに表示
          _buildRow(
            context,
            loc.count,
            info.count.toString(),
          ),
          // 総容量は単位付きで表示
          _buildRow(context, loc.totalVolumeLabel,
              '${info.totalVolume.toString()}${localizeUnit(context, info.unit)}'),
          _buildRow(context, loc.regularPrice, info.regularPrice.toString()),
          _buildRow(context, loc.salePrice, info.salePrice.toString()),
          _buildRow(context, loc.unitPriceLabel, info.unitPrice.toStringAsFixed(2)),
          _buildRow(context, loc.shop, info.shop),
          if (info.approvalUrl.isNotEmpty)
            _buildRow(context, loc.approvalUrl, info.approvalUrl, textStyle),
          if (info.memo.isNotEmpty) _buildRow(context, loc.memo, info.memo, textStyle),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  /// ラベルと値を横並びで表示する共通行ウィジェット
  /// [context] テーマ取得に利用する BuildContext
  /// [label] 左側に表示するラベル
  /// [value] 右側に表示する値
  /// [style] 任意で指定するテキストスタイル
  Widget _buildRow(
      BuildContext context, String label, String value,
      [TextStyle? style]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              // ラベルにも詳細ページ用スタイルを適用
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              // 値のテキストスタイルも統一
              style: style ?? Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
