import 'package:cloud_firestore/cloud_firestore.dart';

import '../../util/firestore_refs.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// Firestore でカテゴリを保存するリポジトリ実装
class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<String> addCategory(Category category) async {
    final doc = await userCollection('categories').add({
      'id': category.id,
      'name': category.name,
      'createdAt': Timestamp.fromDate(category.createdAt),
      if (category.color != null) 'color': category.color,
    });
    return doc.id;
  }

  @override
  Future<void> updateCategory(Category category) async {
    final snapshot = await userCollection('categories')
        .where('id', isEqualTo: category.id)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'name': category.name,
        if (category.color != null)
          'color': category.color
        else
          'color': FieldValue.delete(),
      });
    }
  }
}
