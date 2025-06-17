import 'package:flutter/material.dart';

import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/inventory.dart';
import 'domain/usecases/watch_low_inventory.dart';
import 'i18n/app_localizations.dart';

class BuyListPage extends StatelessWidget {
  final double threshold;
  const BuyListPage({super.key, this.threshold = 0});

  @override
  Widget build(BuildContext context) {
    final watch = WatchLowInventory(InventoryRepositoryImpl());
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).buyListTitle),
      ),
      body: StreamBuilder<List<Inventory>>(
        stream: watch(threshold),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final err = snapshot.error?.toString() ?? 'unknown';
            return Center(child: Text(AppLocalizations.of(context).loadError(err)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).noBuyItems));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final inv in list)
                ListTile(
                  title: Text('${inv.itemType} / ${inv.itemName}'),
                  subtitle: Text('${inv.quantity.toStringAsFixed(1)}${inv.unit}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
