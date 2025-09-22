import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/entities/inventory.dart';
import '../../util/date_time_parser.dart';

/// Firestoreのドキュメントを在庫エンティティへ変換するマッパー
class InventoryMapper {
  /// 定数コンストラクタ
  const InventoryMapper();

  /// Firestoreのクエリドキュメントから在庫エンティティを生成する
  Inventory fromQueryDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _mapInventory(doc.id, doc.data());
  }

  /// Firestoreの単一ドキュメントから在庫エンティティを生成する
  /// 在庫詳細画面で個別の在庫を監視するときに利用する
  Inventory? fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return null;
    }
    return _mapInventory(doc.id, data);
  }

  /// Firestoreの履歴ドキュメントから履歴エンティティを生成する
  /// 在庫詳細画面の履歴タブで利用する
  HistoryEntry fromHistoryDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final timestamp = data['timestamp'];
    return HistoryEntry(
      data['type'] ?? '',
      (data['quantity'] ?? 0).toDouble(),
      timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      before: (data['before'] ?? 0).toDouble(),
      after: (data['after'] ?? 0).toDouble(),
      diff: (data['diff'] ?? 0).toDouble(),
    );
  }

  /// FirestoreのMapデータから在庫エンティティを生成する内部処理
  Inventory _mapInventory(String id, Map<String, dynamic> data) {
    return Inventory(
      id: id,
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
  }
}
