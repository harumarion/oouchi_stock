import 'package:flutter/material.dart';
import 'add_inventory_page.dart';
import 'add_category_page.dart';
import 'inventory_detail_page.dart' show InventoryDetailPage, HistoryEntry, DummyPredictionStrategy;
import 'stocktake_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ← 自動生成された設定ファイル

// アプリのエントリーポイント。Firebase を初期化してから起動する。

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase の初期設定
  runApp(const MyApp()); // アプリのスタート
}

// アプリのルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

// 在庫一覧を表示する画面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<String> categories = ['冷蔵庫', '冷凍庫', '日用品'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('おうちストック'),
          centerTitle: true,
          bottom: TabBar(tabs: [for (final c in categories) Tab(text: c)]),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const AddInventoryPage()),
                  );
                } else if (value == 'stock') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const StocktakePage()),
                  );
                } else if (value == 'category') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const AddCategoryPage()),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'add', child: Text('在庫を追加')),
                const PopupMenuItem(value: 'stock', child: Text('棚卸入力')),
                const PopupMenuItem(value: 'category', child: Text('カテゴリ追加')),
              ],
            )
          ],
        ),
        body: TabBarView(
          children: [for (final c in categories) InventoryList(category: c)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const AddInventoryPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// 指定カテゴリの在庫を一覧表示するウィジェット。
class InventoryList extends StatelessWidget {
  final String category;
  const InventoryList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final err = snapshot.error?.toString() ?? '不明なエラー';
          return Center(child: Text('読み込みエラー: $err'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final data = doc.data();
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryDetailPage(
                      docRef: doc.reference,
                      itemName: data['itemName'] ?? '',
                      unit: data['unit'] ?? '',
                    ),
                  ),
                );
              },
              child: InventoryCard(
                docRef: doc.reference,
                itemName: data['itemName'] ?? '',
                itemType: data['itemType'] ?? '',
                quantity: (data['quantity'] ?? 0).toDouble(),
                unit: data['unit'] ?? '',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// 1件分の在庫情報を表示するカードウィジェット
class InventoryCard extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> docRef;
  // 商品名
  final String itemName;
  final String itemType;
  // 在庫数（小数点第一位まで表示）
  final double quantity;
  final String unit;

  const InventoryCard({
    super.key,
    required this.docRef,
    required this.itemName,
    required this.itemType,
    required this.quantity,
    required this.unit,
  });

  /// 履歴を読み込み購入予測日を計算する。
  Future<DateTime> _loadPrediction() async {
    final history = await docRef
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();
    final list = history.docs
        .map((d) => HistoryEntry(
              d['type'] ?? '',
              (d['quantity'] ?? 0).toDouble(),
              d['timestamp'] as Timestamp,
              before: (d['before'] ?? 0).toDouble(),
              after: (d['after'] ?? 0).toDouble(),
              diff: (d['diff'] ?? 0).toDouble(),
            ))
        .toList();
    final strategy = const DummyPredictionStrategy();
    final predicted = strategy.predict(
        DateTime.now(), list, _currentQuantity(list));
    return predicted;
  }

  double _currentQuantity(List<HistoryEntry> history) {
    if (history.isEmpty) return 0;
    double total = 0;
    for (final h in history.reversed) {
      if (h.type == 'stocktake') {
        total = h.after;
      } else if (h.type == 'add' || h.type == 'bought') {
        total += h.quantity;
      } else if (h.type == 'used') {
        total -= h.quantity;
      }
    }
    return total;
  }

  String _formatDate(DateTime d) {
    return '${d.year}/${d.month}/${d.day}';
  }

  Future<double?> _inputAmountDialog(
    BuildContext context,
    String title,
  ) async {
    final controller = TextEditingController(text: '1.0');
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text);
                Navigator.pop(context, v);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    double amount,
    String type,
  ) async {
    try {
      await docRef.update({'quantity': FieldValue.increment(amount)});
      await docRef.collection('history').add({
        'type': type,
        'quantity': amount.abs(),
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新に失敗しました')),
      );
    }
  }

  Future<void> onUsed(BuildContext context) async {
    final v = await _inputAmountDialog(context, '使った量');
    if (v == null) return;
    await _updateQuantity(context, -v, 'used');
  }

  Future<void> onBought(BuildContext context) async {
    final v = await _inputAmountDialog(context, '買った量');
    if (v == null) return;
    await _updateQuantity(context, v, 'bought');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DateTime>(
      future: _loadPrediction(),
      builder: (context, snapshot) {
        final predicted = snapshot.data;
        final dateText =
            predicted != null ? _formatDate(predicted) : '計算中...';
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
                    Text('$itemType / $itemName',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${quantity.toStringAsFixed(1)}$unit',
                        style: const TextStyle(color: Colors.grey)),
                    Text('予測: $dateText',
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
      },
    );
  }
}
