import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/price_info.dart';
import '../../domain/repositories/price_repository.dart';

class PriceRepositoryImpl implements PriceRepository {
  final FirebaseFirestore _firestore;
  PriceRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> addPriceInfo(PriceInfo info) async {
    final doc = await _firestore.collection('priceInfos').add({
      'inventoryId': info.inventoryId,
      'checkedAt': Timestamp.fromDate(info.checkedAt),
      'category': info.category,
      'itemType': info.itemType,
      'itemName': info.itemName,
      'count': info.count,
      'unit': info.unit,
      'volume': info.volume,
      'totalVolume': info.totalVolume,
      'price': info.price,
      'shop': info.shop,
      'unitPrice': info.unitPrice,
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  @override
  Stream<List<PriceInfo>> watchByCategory(String category) {
    return _firestore
        .collection('priceInfos')
        .where('category', isEqualTo: category)
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<PriceInfo>> watchByType(String category, String itemType) {
    return _firestore
        .collection('priceInfos')
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
      price: (data['price'] ?? 0).toDouble(),
      shop: data['shop'] ?? '',
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
    );
  }

  @override
  Future<void> deletePriceInfo(String id) async {
    await _firestore.collection('priceInfos').doc(id).delete();
  }
}
