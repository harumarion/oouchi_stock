import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('オフライン永続化が有効か', () {
    expect(FirebaseFirestore.instance.settings.persistenceEnabled, isTrue);
  });
}
