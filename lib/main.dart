import 'package:flutter/material.dart';
import 'add_inventory_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'おうちストック',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('おうちストック'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('inventory')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('読み込みエラー'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data();
              return InventoryCard(
                docRef: doc.reference,
                itemName: data['itemName'] ?? '',
                quantity: data['quantity'] ?? 0,
                unit: data['unit'] ?? '',
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddInventoryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InventoryCard extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  final String itemName;
  final int quantity;
  final String unit;

  const InventoryCard({
    super.key,
    required this.docRef,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });

  Future<void> onUsed(BuildContext context) async {
    try {
      await docRef.update({'quantity': FieldValue.increment(-1)});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新に失敗しました')),
      );
    }
  }

  Future<void> onBought(BuildContext context) async {
    try {
      await docRef.update({'quantity': FieldValue.increment(1)});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text('$quantity$unit',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => onUsed(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onBought(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
