import 'package:flutter/material.dart';

import 'data/repositories/price_repository_impl.dart';
import 'domain/entities/price_info.dart';
import 'domain/usecases/delete_price_info.dart';
import 'domain/usecases/watch_price_by_type.dart';

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
            final err = snapshot.error?.toString() ?? '不明なエラー';
            return Center(child: Text('読み込みエラー: $err'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          return ListView(
            children: [
              for (final p in list)
                ListTile(
                  title: Text(p.itemName),
                  subtitle: Text(
                      '${_formatDate(p.checkedAt)} 数:${p.count} ${p.unit} 容量:${p.volume} 合計:${p.totalVolume} 値段:${p.price} 購入元:${p.shop} 単価:${p.unitPrice.toStringAsFixed(2)}'),
                  onLongPress: () async {
                    final res = await showModalBottomSheet<String>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('削除'),
                          onTap: () => Navigator.pop(context, 'delete'),
                        ),
                      ),
                    );
                    if (res == 'delete') {
                      await deleter(p.id);
                    }
                  },
                )
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }
}
