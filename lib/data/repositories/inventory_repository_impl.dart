import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/inventory_repository.dart';

// InventoryRepositoryImpl: Firestore を利用した在庫リポジトリ実装
class InventoryRepositoryImpl implements InventoryRepository {
  // Firestore インスタンス
  final FirebaseFirestore _firestore;
  InventoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Inventory>> watchByCategory(String category) {
    return userCollection('inventory')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Inventory(
                id: doc.id,
                itemName: data['itemName'] ?? '',
                category: data['category'] ?? '',
                itemType: data['itemType'] ?? '',
                quantity: (data['quantity'] ?? 0).toDouble(),
                unit: data['unit'] ?? '',
                note: data['note'] ?? '',
                createdAt: parseDateTime(data['createdAt']),
              );
            }).toList());
  }

  @override
  Future<List<Inventory>> fetchAll() async {
    final snapshot = await userCollection('inventory')
        .orderBy('createdAt')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Inventory(
        id: doc.id,
        itemName: data['itemName'] ?? '',
        category: data['category'] ?? '',
        itemType: data['itemType'] ?? '',
        quantity: (data['quantity'] ?? 0).toDouble(),
        unit: data['unit'] ?? '',
        note: data['note'] ?? '',
        createdAt: parseDateTime(data['createdAt']),
      );
    }).toList();
  }

  @override
  Future<String> addInventory(Inventory inventory) async {
    final doc = await userCollection('inventory').add({
      'itemName': inventory.itemName,
      'category': inventory.category,
      'itemType': inventory.itemType,
      'quantity': inventory.quantity,
      'unit': inventory.unit,
      'note': inventory.note,
      'createdAt': Timestamp.fromDate(inventory.createdAt),
    });
    await doc.collection('history').add({
      'type': 'add',
      'quantity': inventory.quantity,
      'timestamp': Timestamp.now(),
    });
    return doc.id;
  }

  // 数量変更履歴を保存し在庫数量を更新する
  @override
  Future<void> updateQuantity(String id, double amount, String type) async {
    final doc = userCollection('inventory').doc(id);
    try {
      final snapshot = await doc.get();
      final data = snapshot.data() as Map<String, dynamic>?;
      final before = (data?['quantity'] ?? 0).toDouble();
      final after = before + amount;

      await doc.update({'quantity': FieldValue.increment(amount)});
      await doc.collection('history').add({
        'type': type,
        'quantity': amount.abs(),
        'before': before,
        'after': after,
        'diff': amount,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // オフライン時や取得失敗時は例外を投げて上位でハンドリングする
      rethrow;
    }
  }

  @override
  Future<void> updateInventory(Inventory inventory) async {
    await userCollection('inventory').doc(inventory.id).update({
      'itemName': inventory.itemName,
      'category': inventory.category,
      'itemType': inventory.itemType,
      'unit': inventory.unit,
      'note': inventory.note,
    });
  }

  @override
  Stream<Inventory?> watchInventory(String inventoryId) {
    return userCollection('inventory')
        .doc(inventoryId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return Inventory(
        id: doc.id,
        itemName: data['itemName'] ?? '',
        category: data['category'] ?? '',
        itemType: data['itemType'] ?? '',
        quantity: (data['quantity'] ?? 0).toDouble(),
        unit: data['unit'] ?? '',
        note: data['note'] ?? '',
        createdAt: parseDateTime(data['createdAt']),
      );
    });
  }

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) {
    return userCollection('inventory')
        .doc(inventoryId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) {
              final data = d.data();
              final ts = data['timestamp'];
              return HistoryEntry(
                data['type'] ?? '',
                (data['quantity'] ?? 0).toDouble(),
                ts is Timestamp ? ts.toDate() : DateTime.now(),
                before: (data['before'] ?? 0).toDouble(),
                after: (data['after'] ?? 0).toDouble(),
                diff: (data['diff'] ?? 0).toDouble(),
              );
            }).toList());
  }

  @override
  Future<void> stocktake(
      String id, double before, double after, double diff) async {
    final doc = userCollection('inventory').doc(id);
    await doc.update({'quantity': after});
    await doc.collection('history').add({
      'type': 'stocktake',
      'before': before,
      'after': after,
      'diff': diff,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteInventory(String id) async {
    await userCollection('inventory').doc(id).delete();
  }

  @override
  Stream<List<Inventory>> watchNeedsBuy(double threshold) {
    return userCollection('inventory')
        .where('quantity', isLessThanOrEqualTo: threshold)
        .orderBy('quantity')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Inventory(
                id: doc.id,
                itemName: data['itemName'] ?? '',
                category: data['category'] ?? '',
                itemType: data['itemType'] ?? '',
                quantity: (data['quantity'] ?? 0).toDouble(),
                unit: data['unit'] ?? '',
                note: data['note'] ?? '',
                createdAt: parseDateTime(data['createdAt']),
              );
            }).toList());
  }
}
