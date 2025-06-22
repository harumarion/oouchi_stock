import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/firestore_refs.dart';
import '../../util/date_time_parser.dart';

import '../../domain/entities/inventory.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/inventory_repository.dart';

/// Firestore を利用した在庫リポジトリ実装
class InventoryRepositoryImpl implements InventoryRepository {
  /// デフォルトコンストラクタ
  InventoryRepositoryImpl();

  @override
  /// カテゴリごとの在庫を監視する
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
                volume: (data['volume'] ?? 0).toDouble(),
                totalVolume: (data['totalVolume'] ?? 0).toDouble(),
                unit: data['unit'] ?? '',
                note: data['note'] ?? '',
                monthlyConsumption:
                    (data['monthlyConsumption'] ?? 0).toDouble(),
                createdAt: parseDateTime(data['createdAt']),
              );
            }).toList());
  }

  @override
  /// 全在庫を取得する
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
        volume: (data['volume'] ?? 0).toDouble(),
        totalVolume: (data['totalVolume'] ?? 0).toDouble(),
        unit: data['unit'] ?? '',
        note: data['note'] ?? '',
        monthlyConsumption: (data['monthlyConsumption'] ?? 0).toDouble(),
        createdAt: parseDateTime(data['createdAt']),
      );
    }).toList();
  }

  @override
  /// 在庫を追加してIDを返す
  Future<String> addInventory(Inventory inventory) async {
    final doc = await userCollection('inventory').add({
      'itemName': inventory.itemName,
      'category': inventory.category,
      'itemType': inventory.itemType,
      'quantity': inventory.quantity,
      'volume': inventory.volume,
      'totalVolume': inventory.totalVolume,
      'unit': inventory.unit,
      'note': inventory.note,
      'monthlyConsumption': inventory.monthlyConsumption,
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
  /// 数量変更履歴を保存し在庫数量を更新する
  /// 在庫一覧画面のカードで+/-ボタンを押したときに実行される
  Future<void> updateQuantity(String id, double amount, String type) async {
    final doc = userCollection('inventory').doc(id);
    try {
      final snapshot = await doc.get();
      // Firestore ドキュメントから取得したデータ。null の可能性があるため Map を nullable として扱う
      final Map<String, dynamic>? data = snapshot.data();
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
      await _recalculateMonthlyConsumption(id);
    } catch (e) {
      // オフライン時や取得失敗時は例外を投げて上位でハンドリングする
      rethrow;
    }
  }

  @override
  /// 在庫情報を更新する
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
  /// 指定IDの在庫情報を監視する
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
        volume: (data['volume'] ?? 0).toDouble(),
        totalVolume: (data['totalVolume'] ?? 0).toDouble(),
        unit: data['unit'] ?? '',
        note: data['note'] ?? '',
        monthlyConsumption: (data['monthlyConsumption'] ?? 0).toDouble(),
        createdAt: parseDateTime(data['createdAt']),
      );
    });
  }

  @override
  /// 指定在庫の履歴を監視する
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
  /// 棚卸し結果を記録する
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
    await _recalculateMonthlyConsumption(id);
  }

  @override
  /// 在庫を削除する
  Future<void> deleteInventory(String id) async {
    await userCollection('inventory').doc(id).delete();
  }

  @override
  /// 残量が一定以下の在庫を監視する
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
                volume: (data['volume'] ?? 0).toDouble(),
                totalVolume: (data['totalVolume'] ?? 0).toDouble(),
                unit: data['unit'] ?? '',
                note: data['note'] ?? '',
                monthlyConsumption:
                    (data['monthlyConsumption'] ?? 0).toDouble(),
                createdAt: parseDateTime(data['createdAt']),
              );
            }).toList());
  }

  /// 履歴から月あたりの消費量を再計算する
  Future<void> _recalculateMonthlyConsumption(String id) async {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final history = await userCollection('inventory')
        .doc(id)
        .collection('history')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(monthAgo))
        .get();
    double used = 0;
    for (final doc in history.docs) {
      final data = doc.data();
      if (data['type'] == 'used') {
        used += (data['quantity'] ?? 0).toDouble();
      }
    }
    await userCollection('inventory')
        .doc(id)
        .update({'monthlyConsumption': used});
  }
}
