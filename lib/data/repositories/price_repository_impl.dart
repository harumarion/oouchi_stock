import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/firestore_refs.dart';

import '../../domain/entities/price_info.dart';
import '../../domain/repositories/price_repository.dart';

/// Firestore を利用した価格情報のリポジトリ実装
class PriceRepositoryImpl implements PriceRepository {
  /// デフォルトコンストラクタ
  PriceRepositoryImpl();

  @override
  /// 価格情報を追加してIDを返す
  Future<String> addPriceInfo(PriceInfo info) async {
    final doc = await userCollection('priceInfos').add({
      'inventoryId': info.inventoryId,
      'checkedAt': Timestamp.fromDate(info.checkedAt),
      'category': info.category,
      'itemType': info.itemType,
      'itemName': info.itemName,
      'count': info.count,
      'unit': info.unit,
      'volume': info.volume,
      'totalVolume': info.totalVolume,
      // 通常価格とセール価格の両方を保存
      'regularPrice': info.regularPrice,
      'salePrice': info.salePrice,
      // 旧フィールドとの互換のため price も保存
      'price': info.salePrice,
      'shop': info.shop,
      'approvalUrl': info.approvalUrl,
      'memo': info.memo,
      'unitPrice': info.unitPrice,
      // セール期限
      'expiry': Timestamp.fromDate(info.expiry),
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  @override
  /// 価格情報を更新する
  Future<void> updatePriceInfo(PriceInfo info) async {
    await userCollection('priceInfos').doc(info.id).update({
      'inventoryId': info.inventoryId,
      'checkedAt': Timestamp.fromDate(info.checkedAt),
      'category': info.category,
      'itemType': info.itemType,
      'itemName': info.itemName,
      'count': info.count,
      'unit': info.unit,
      'volume': info.volume,
      'totalVolume': info.totalVolume,
      'regularPrice': info.regularPrice,
      'salePrice': info.salePrice,
      'price': info.salePrice,
      'shop': info.shop,
      'approvalUrl': info.approvalUrl,
      'memo': info.memo,
      'unitPrice': info.unitPrice,
      'expiry': Timestamp.fromDate(info.expiry),
    });
  }

  @override
  /// カテゴリ別の価格情報を監視する
  Stream<List<PriceInfo>> watchByCategory(String category) {
    return userCollection('priceInfos')
        .where('category', isEqualTo: category)
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  /// カテゴリと品種で価格情報を監視する
  Stream<List<PriceInfo>> watchByType(String category, String itemType) {
    return userCollection('priceInfos')
        .where('category', isEqualTo: category)
        .where('itemType', isEqualTo: itemType)
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  PriceInfo _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return PriceInfo(
      id: doc.id,
      inventoryId: data['inventoryId'] ?? '',
      checkedAt: (data['checkedAt'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      itemType: data['itemType'] ?? '',
      itemName: data['itemName'] ?? '',
      count: (data['count'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      volume: (data['volume'] ?? 0).toDouble(),
      totalVolume: (data['totalVolume'] ?? 0).toDouble(),
      regularPrice: (data['regularPrice'] ?? 0).toDouble(),
      salePrice: (data['salePrice'] ?? data['price'] ?? 0).toDouble(),
      shop: data['shop'] ?? '',
      approvalUrl: data['approvalUrl'] ?? '',
      memo: data['memo'] ?? '',
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      // ドキュメントに存在しない場合は checkedAt を使用
      expiry: (data['expiry'] as Timestamp?)?.toDate() ??
          (data['checkedAt'] as Timestamp).toDate(),
    );
  }

  @override
  /// 価格情報を削除する
  Future<void> deletePriceInfo(String id) async {
    await userCollection('priceInfos').doc(id).delete();
  }

  @override
  /// 在庫IDに紐づくセール情報を削除する
  Future<void> deleteByInventoryId(String inventoryId) async {
    final snapshot = await userCollection('priceInfos')
        .where('inventoryId', isEqualTo: inventoryId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
