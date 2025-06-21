import 'package:flutter/material.dart';
import 'buy_list_page.dart';
import 'inventory_page.dart';
import 'home_page.dart';
import 'add_inventory_page.dart';
import 'add_price_page.dart';
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

  // 各インデックスに対応する画面のリスト
  // 0: 買い物リスト画面
  // 1: 在庫一覧画面
  // 2: 買い物予報画面
  // 3: 商品追加画面
  // 4: セール情報追加画面
  late final List<Widget> _pages = [
    // 非 const コンストラクタのため const を付けない
    BuyListPage(),
    const InventoryPage(),
    const HomePage(),
    const AddInventoryPage(),
    const AddPricePage(),
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
        onTap: (i) => setState(() => _index = i),
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
          // 商品追加
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box),
            label: AppLocalizations.of(context)!.addItem,
          ),
          // セール情報追加
          BottomNavigationBarItem(
            icon: const Icon(Icons.price_change),
            label: AppLocalizations.of(context)!.priceAddTitle,
          ),
        ],
      ),
    );
  }
}
