import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/data/repositories/buy_prediction_repository_impl.dart';

void main() {
  test('BuyPredictionRepository add and remove', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = BuyPredictionRepositoryImpl();
    await repo.addItem(
        const BuyItem('コーヒー', 'その他', null, BuyItemReason.manual));
    var list = await repo.watchItems().first;
    expect(list.length, 1);
    expect(list.first.name, 'コーヒー');
    await repo.removeItem(
        const BuyItem('コーヒー', 'その他', null, BuyItemReason.manual));
    list = await repo.watchItems().first;
    expect(list.isEmpty, true);
  });
}
