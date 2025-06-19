import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ユーザーごとのコレクション参照を取得するヘルパー
CollectionReference<Map<String, dynamic>> userCollection(String name) {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance.collection('users').doc(uid).collection(name);
}
