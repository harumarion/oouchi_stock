import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final FirebaseFirestore _firestore;
  InventoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Inventory>> watchByCategory(String category) {
    return _firestore
        .collection('inventory')
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
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }

  @override
  Future<List<Inventory>> fetchAll() async {
    final snapshot = await _firestore
        .collection('inventory')
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
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<String> addInventory(Inventory inventory) async {
    final doc = await _firestore.collection('inventory').add({
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

  @override
  Future<void> updateQuantity(String id, double amount, String type) async {
    final doc = _firestore.collection('inventory').doc(id);
    await doc.update({'quantity': FieldValue.increment(amount)});
    await doc.collection('history').add({
      'type': type,
      'quantity': amount.abs(),
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Stream<List<HistoryEntry>> watchHistory(String inventoryId) {
    return _firestore
        .collection('inventory')
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
    final doc = _firestore.collection('inventory').doc(id);
    await doc.update({'quantity': after});
    await doc.collection('history').add({
      'type': 'stocktake',
      'before': before,
      'after': after,
      'diff': diff,
      'timestamp': Timestamp.now(),
    });
  }
}
