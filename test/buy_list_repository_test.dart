import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oouchi_stock/domain/entities/buy_item.dart';
import 'package:oouchi_stock/data/repositories/buy_list_repository_impl.dart';

void main() {
  test('BuyListRepository add and remove', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = BuyListRepositoryImpl();
    await repo.addItem(const BuyItem('コーヒー', 'その他'));
    var list = await repo.watchItems().first;
    expect(list.length, 1);
    expect(list.first.name, 'コーヒー');
    await repo.removeItem(const BuyItem('コーヒー', 'その他'));
    list = await repo.watchItems().first;
    expect(list.isEmpty, true);
  });

  test('ignored id functions', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = BuyListRepositoryImpl();
    await repo.addIgnoredId('id1');
    var ids = await repo.loadIgnoredIds();
    expect(ids.contains('id1'), true);
    await repo.removeIgnoredId('id1');
    ids = await repo.loadIgnoredIds();
    expect(ids.contains('id1'), false);
  });
}
