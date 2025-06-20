import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oouchi_stock/util/date_time_parser.dart';

void main() {
  test('Timestamp と String から DateTime を解析できる', () {
    final date = DateTime(2020, 1, 1);
    final ts = Timestamp.fromDate(date);
    expect(parseDateTime(ts), date);
    expect(parseDateTime('2020-01-02T00:00:00.000'), DateTime(2020, 1, 2));
  });
}
