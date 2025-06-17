import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';

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
            final err = snapshot.error?.toString() ?? 'unknown';
            return Center(child: Text(AppLocalizations.of(context)!.loadError(err)));
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
                      '${_formatDate(p.checkedAt)} '
                      '${AppLocalizations.of(context)!.priceSummary(
                          count: p.count.toString(),
                          unitStr: p.unit,
                          volume: p.volume.toString(),
                          total: p.totalVolume.toString(),
                          price: p.price.toString(),
                          shop: p.shop,
                          unitPrice: p.unitPrice.toStringAsFixed(2))}'),
                  onLongPress: () async {
                    final res = await showModalBottomSheet<String>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context)!.delete),
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
