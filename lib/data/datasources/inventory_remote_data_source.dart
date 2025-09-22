import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../util/firestore_refs.dart';

/// Firestoreへの在庫関連アクセスを担当するデータソース
/// 在庫一覧画面や在庫詳細画面が利用する永続化処理を集約する
class InventoryRemoteDataSource {
  /// 定数コンストラクタ
  const InventoryRemoteDataSource();

  /// Firestore上の在庫コレクション参照を取得する
  CollectionReference<Map<String, dynamic>> get _collection =>
      userCollection('inventory');

  /// カテゴリ別の在庫ドキュメントを監視する
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      watchInventoriesByCategory(String category) {
    return _collection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// 全在庫ドキュメントを取得する
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchAllInventories() async {
    final snapshot = await _collection.orderBy('createdAt').get();
    return snapshot.docs;
  }

  /// Firestoreに在庫を追加し、履歴も初期登録する
  Future<String> addInventory(
      Map<String, dynamic> inventoryData, double initialQuantity) async {
    final doc = await _collection.add(inventoryData);
    await doc.collection('history').add({
      'type': 'add',
      'quantity': initialQuantity,
      'timestamp': Timestamp.now(),
    });
    return doc.id;
  }

  /// 在庫数量を変更し履歴を記録する
  Future<void> updateQuantity(String id, double amount, String type) async {
    final doc = _collection.doc(id);
    try {
      final snapshot = await doc.get();
      final data = snapshot.data();
      if (data == null) {
        log('inventory document not found for id=$id');
        return;
      }
      final before = (data['quantity'] ?? 0).toDouble();
      final volume = (data['volume'] ?? 0).toDouble();
      final beforeVolume = (data['totalVolume'] ?? before * volume).toDouble();
      final after = before + amount;
      final diffVolume = amount * volume;
      final afterVolume = beforeVolume + diffVolume;

      await doc.update({
        'quantity': after,
        'totalVolume': afterVolume,
      });
      await doc.collection('history').add({
        'type': type,
        'quantity': diffVolume.abs(),
        'before': beforeVolume,
        'after': afterVolume,
        'diff': diffVolume,
        'timestamp': Timestamp.now(),
      });
      await _recalculateMonthlyConsumption(id);
    } catch (e, stackTrace) {
      log('failed to update inventory quantity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 在庫情報を更新する
  Future<void> updateInventory(
      String id, Map<String, dynamic> updateData) async {
    await _collection.doc(id).update(updateData);
  }

  /// 個別の在庫ドキュメントを監視する
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchInventory(
      String id) {
    return _collection.doc(id).snapshots();
  }

  /// 履歴ドキュメントを監視する
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchHistory(
      String id) {
    return _collection
        .doc(id)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// 棚卸し結果を記録する
  Future<void> stocktake(
      String id, double before, double after, double diff) async {
    final doc = _collection.doc(id);
    final snapshot = await doc.get();
    final data = snapshot.data();
    final volume = (data?['volume'] ?? 0).toDouble();
    final beforeVolume = before * volume;
    final afterVolume = after * volume;
    final diffVolume = diff * volume;
    await doc.update({
      'quantity': after,
      'totalVolume': afterVolume,
    });
    await doc.collection('history').add({
      'type': 'stocktake',
      'before': beforeVolume,
      'after': afterVolume,
      'diff': diffVolume,
      'timestamp': Timestamp.now(),
    });
    await _recalculateMonthlyConsumption(id);
  }

  /// 在庫を削除する
  Future<void> deleteInventory(String id) async {
    final doc = _collection.doc(id);
    final history = await doc.collection('history').get();
    for (final record in history.docs) {
      await record.reference.delete();
    }
    await doc.delete();
  }

  /// 残量が閾値以下の在庫を監視する
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchNeedsBuy(
      double threshold) {
    return _collection
        .where('totalVolume', isLessThanOrEqualTo: threshold)
        .orderBy('totalVolume')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// 履歴から月あたりの消費量を再計算する内部処理
  Future<void> _recalculateMonthlyConsumption(String id) async {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final history = await _collection
        .doc(id)
        .collection('history')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthAgo))
        .get();
    double used = 0;
    for (final doc in history.docs) {
      final data = doc.data();
      if (data['type'] == 'used') {
        used += (data['diff'] ?? 0).abs().toDouble();
      }
    }
    await _collection.doc(id).update({'monthlyConsumption': used});
  }
}
