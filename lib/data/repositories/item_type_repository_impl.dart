import 'package:cloud_firestore/cloud_firestore.dart';

import '../../util/firestore_refs.dart';
import '../../domain/entities/item_type.dart';
import '../../domain/repositories/item_type_repository.dart';

/// Firestore で品種を保存するリポジトリ実装
class ItemTypeRepositoryImpl implements ItemTypeRepository {
  @override
  Future<String> addItemType(ItemType itemType) async {
    final doc = await userCollection('itemTypes').add({
      'id': itemType.id,
      'category': itemType.category,
      'name': itemType.name,
      'createdAt': Timestamp.fromDate(itemType.createdAt),
    });
    return doc.id;
  }

  @override
  Future<void> updateItemType(ItemType itemType) async {
    final snapshot = await userCollection('itemTypes')
        .where('id', isEqualTo: itemType.id)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'name': itemType.name,
        'category': itemType.category,
      });
    }
  }
}
