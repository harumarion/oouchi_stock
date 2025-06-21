import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_refs.dart';
import 'util/date_time_parser.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'add_category_page.dart';
import 'widgets/settings_menu_button.dart';
// 在庫カードウィジェット
import 'widgets/inventory_card.dart';
import 'widgets/prediction_card.dart';
// 在庫詳細画面
import 'inventory_detail_page.dart';
import 'main.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/entities/category.dart';
import 'domain/entities/inventory.dart';
import 'domain/entities/category_order.dart';
import 'domain/usecases/calculate_days_left.dart';
import 'domain/entities/buy_list_condition_settings.dart';
import 'data/repositories/buy_list_repository_impl.dart';
import 'domain/entities/buy_item.dart';
import 'domain/usecases/add_buy_item.dart';
import 'data/repositories/buy_prediction_repository_impl.dart';
import 'domain/usecases/watch_prediction_items.dart';
import 'domain/usecases/remove_prediction_item.dart';

/// ホーム画面。起動時に表示され、買い物リストを管理する。
class HomePage extends StatefulWidget {
  /// 起動時に受け取るカテゴリ一覧。null の場合は Firestore から取得する
  final List<Category>? categories;
  const HomePage({super.key, this.categories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Firestore から取得したカテゴリ一覧
  List<Category> _categories = [];
  /// カテゴリが読み込み済みかどうかのフラグ
  bool _categoriesLoaded = false;
  /// カテゴリコレクションを監視するストリーム購読
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catSub;
  /// 買い物予報の条件設定
  BuyListConditionSettings? _conditionSettings;

  /// 在庫の残り日数計算用ユースケース
  final CalculateDaysLeft _calcUsecase =
      CalculateDaysLeft(InventoryRepositoryImpl());


  // 買い物リストへ商品を追加するユースケース
  final AddBuyItem _addBuyItem = AddBuyItem(BuyListRepositoryImpl());

  // 予報リストの監視・操作用
  final _predictionRepo = BuyPredictionRepositoryImpl();
  late final WatchPredictionItems _watchPrediction =
      WatchPredictionItems(_predictionRepo);
  late final RemovePredictionItem _removePrediction =
      RemovePredictionItem(_predictionRepo);

  /// 設定画面から戻った際にカテゴリリストを更新する
  void _updateCategories(List<Category> list) {
    setState(() {
      _categories = List.from(list);
      _categoriesLoaded = true;
    });
  }

  Future<void> _loadCondition() async {
    // 設定画面から戻った際にも呼ばれ、買い物予報条件を再読み込みする
    final s = await loadBuyListConditionSettings();
    setState(() => _conditionSettings = s);
  }

  /// ホーム画面の在庫カード表示時に履歴から残り日数を計算する
  Future<int> _calcDaysLeft(Inventory inv) async {
    // インベントリカード描画時に呼び出される
    // 新設したユースケースに処理を委譲する
    return _calcUsecase(inv);
  }

  @override
  void initState() {
    super.initState();
    _loadCondition();
    // 引数でカテゴリが渡され、1件以上存在する場合のみ利用する
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _categories = List.from(widget.categories!);
      applyCategoryOrder(_categories).then((list) {
        setState(() {
          _categories = list;
          _categoriesLoaded = true;
        });
      });
    } else {
      // カテゴリが空の場合は Firestore を監視して更新を待つ
      // Firestore からカテゴリ一覧を取得して監視
      // カテゴリに変更があったときに実行される
      _catSub = userCollection('categories')
          .orderBy('createdAt')
          .snapshots()
          .listen((snapshot) async {
        var list = snapshot.docs.map((d) {
          final data = d.data();
          return Category(
            id: data['id'] ?? 0,
            name: data['name'] ?? '',
            createdAt: parseDateTime(data['createdAt']),
          );
        }).toList();
        list = await applyCategoryOrder(list);
        setState(() {
          _categories = list;
          _categoriesLoaded = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面描画。カテゴリが読み込まれるまではローディングを表示
    if (!_categoriesLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // カテゴリがまだ存在しない場合は案内テキストと追加ボタンを表示
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // カテゴリ未登録メッセージ
              Text(AppLocalizations.of(context)!.noCategories),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // カテゴリ追加画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCategoryPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.addCategory),
              ),
            ],
          ),
        ),
      );
    }

    // 買い物予報条件が未読込の場合はローディングを表示
    // 設定変更後の復帰直後などに発生する
    if (_conditionSettings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // 画面表示時に在庫一覧を取得
    // 画面描画時に在庫一覧を取得する
    return StreamBuilder<List<BuyItem>>( 
      stream: _watchPrediction(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.buyListTitle)),
            body: Center(child: Text(AppLocalizations.of(context)!.noBuyItems)),
          );
        }
        final map = {for (final c in _categories) c.name: <BuyItem>[]};
        for (final item in items) {
          map[item.category]?.add(item);
        }
        return DefaultTabController(
          length: _categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.buyListTitle),
              actions: [
                SettingsMenuButton(
                  categories: _categories,
                  onCategoriesChanged: _updateCategories,
                  onLocaleChanged: (l) => context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
                  onConditionChanged: _loadCondition,
                )
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (final c in _categories)
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Tab(text: c.name),
                    )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final c in _categories)
                  map[c.name]!.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noBuyItems))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final item in map[c.name]!)
                              PredictionCard(
                                item: item,
                                categories: _categories,
                                repository: InventoryRepositoryImpl(),
                                addUsecase: _addBuyItem,
                                removeUsecase: _removePrediction,
                                calcDaysLeft: _calcDaysLeft,
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
