import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AddInventoryView {
  void showSaveSuccess();
  void showSaveError(String message);
}

class AddInventoryPresenter {
  AddInventoryPresenter(this.view, {FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  final AddInventoryView view;
  final FirebaseFirestore firestore;

  Future<void> saveItem({
    required String itemName,
    required String category,
    required String itemType,
    required double quantity,
    required String unit,
    required String note,
  }) async {
    try {
      final doc = await firestore.collection('inventory').add({
        'itemName': itemName,
        'category': category,
        'itemType': itemType,
        'quantity': quantity,
        'unit': unit,
        'note': note,
        'createdAt': Timestamp.now(),
      });
      await doc.collection('history').add({
        'type': 'add',
        'quantity': quantity,
        'timestamp': Timestamp.now(),
      });
      view.showSaveSuccess();
    } on FirebaseException catch (e) {
      view.showSaveError(e.message ?? e.code);
    } catch (_) {
      view.showSaveError('保存に失敗しました');
    }
  }
}
