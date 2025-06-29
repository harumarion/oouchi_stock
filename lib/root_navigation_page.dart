import 'package:flutter/material.dart';
import 'buy_list_page.dart';
import 'inventory_page.dart';
import 'home_page.dart';
import 'add_inventory_page.dart';
import 'add_price_page.dart'; // セール情報追加画面
import 'price_list_page.dart'; // セール情報管理画面
import 'i18n/app_localizations.dart';
import 'widgets/ad_banner.dart';

/// アプリのメイン画面。下部のナビゲーションバーで各画面を切り替える
class RootNavigationPage extends StatefulWidget {
  const RootNavigationPage({super.key});

  @override
  State<RootNavigationPage> createState() => _RootNavigationPageState();
}

class _RootNavigationPageState extends State<RootNavigationPage> {
  int _index = 0; // 選択中のメニュー
  // 買い物リスト画面の状態を取得するためのキー
  final GlobalKey<BuyListPageState> _buyListKey = GlobalKey();
  // 在庫一覧画面の状態を取得するためのキー
  final GlobalKey<InventoryPageState> _inventoryKey = GlobalKey();

  // 各インデックスに対応する画面のリスト
  // 0: 買い物リスト画面
  // 1: 在庫一覧画面
  // 2: 買い物予報画面
  // 3: セール情報管理画面
  late final List<Widget> _pages = [
    // 非 const コンストラクタのため const を付けない
    BuyListPage(key: _buyListKey),
    InventoryPage(key: _inventoryKey),
    const HomePage(),
    const PriceListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // 画面をインデックスで切り替える
    return Scaffold(
      body: Column(
        children: [
          // 各画面を表示する領域
          Expanded(child: IndexedStack(index: _index, children: _pages)),
          // 画面下部に常に表示する広告バナー
          const AdBanner(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          // タブ切り替え時に各画面を最新状態へ更新
          if (i == 0) {
            _buyListKey.currentState?.refresh();
          } else if (i == 1) {
            _inventoryKey.currentState?.refresh();
          }
        },
        items: [
          // 買い物リスト
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: AppLocalizations.of(context)!.buyList,
          ),
          // 在庫一覧
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: AppLocalizations.of(context)!.inventoryList,
          ),
          // 買い物予報
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_note),
            label: AppLocalizations.of(context)!.buyListTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.price_change),
            label: AppLocalizations.of(context)!.saleInfo,
          ),
        ],
      ),
    );
  }
}
