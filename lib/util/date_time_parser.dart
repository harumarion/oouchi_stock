import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore の Timestamp または ISO8601 形式の文字列から DateTime を生成するヘルパー
DateTime parseDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
