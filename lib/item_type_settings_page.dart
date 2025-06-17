import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'domain/entities/item_type.dart';
import 'domain/entities/category.dart';
import 'add_item_type_page.dart';
import 'edit_item_type_page.dart';
import 'default_item_types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemTypeSettingsPage extends StatefulWidget {
  final List<Category> categories;
  const ItemTypeSettingsPage({super.key, required this.categories});

  @override
  State<ItemTypeSettingsPage> createState() => _ItemTypeSettingsPageState();
}

class _ItemTypeSettingsPageState extends State<ItemTypeSettingsPage> {
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;
  List<ItemType> _list = [];

  @override
  void initState() {
    super.initState();
    _sub = FirebaseFirestore.instance
        .collection('itemTypes')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await insertDefaultItemTypes();
        return;
      }
      setState(() {
        _list = snapshot.docs.map((d) {
          final data = d.data();
          return ItemType(
            id: data['id'] ?? 0,
            category: data['category'] ?? '',
            name: data['name'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _delete(ItemType item) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('itemTypes')
          .where('id', isEqualTo: item.id)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).deleted)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).deleteFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).itemTypeSettingsTitle)),
      body: ListView(
        children: [
          for (final t in _list)
            ListTile(
              title: Text('${t.category} / ${t.name}'),
              onLongPress: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppLocalizations.of(context).itemTypeEditTitle),
                          onTap: () => Navigator.pop(context, 'edit'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(AppLocalizations.of(context).delete),
                          onTap: () => Navigator.pop(context, 'delete'),
                        ),
                      ],
                    ),
                  ),
                );
                if (result == 'delete') {
                  _delete(t);
                } else if (result == 'edit') {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditItemTypePage(
                        itemType: t,
                        categories: widget.categories,
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemTypePage(categories: widget.categories),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
