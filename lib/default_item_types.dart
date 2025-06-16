import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, List<String>> defaultItemTypes = {
  '冷蔵庫': ['その他'],
  '冷凍庫': ['その他'],
  '日用品': [
    '柔軟剤',
    '洗濯洗剤',
    '食洗器洗剤',
    '衣料用漂白剤',
    'シャンプー',
    'コンディショナー',
    'オシャレ洗剤',
    'トイレ洗剤',
    '台所洗剤',
    '台所洗剤スプレー',
    '台所漂白',
    '台所漂白スプレー',
    'トイレ洗剤ふき',
    '台所清掃スプレー',
    'ハンドソープ',
  ],
};

Future<void> insertDefaultItemTypes() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('itemTypes').get();
  if (snapshot.docs.isNotEmpty) return;
  final batch = FirebaseFirestore.instance.batch();
  final random = Random();
  final now = Timestamp.now();
  defaultItemTypes.forEach((category, list) {
    for (final name in list) {
      final doc = FirebaseFirestore.instance.collection('itemTypes').doc();
      batch.set(doc, {
        'id': random.nextInt(0xffffffff),
        'category': category,
        'name': name,
        'createdAt': now,
      });
    }
  });
  await batch.commit();
}
