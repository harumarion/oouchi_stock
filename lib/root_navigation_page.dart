import 'package:flutter/material.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'price_list_page.dart';
import 'sale_list_page.dart';
import 'add_inventory_page.dart';
import 'settings_page.dart';
import 'main.dart';
import 'i18n/app_localizations.dart';

/// アプリのメイン画面。下部のナビゲーションバーで各画面を切り替える
class RootNavigationPage extends StatefulWidget {
  const RootNavigationPage({super.key});

  @override
  State<RootNavigationPage> createState() => _RootNavigationPageState();
}

class _RootNavigationPageState extends State<RootNavigationPage> {
  int _index = 0; // 選択中のメニュー

  // 各インデックスに対応する画面のリスト
  // 0: ホーム画面
  // 1: 在庫一覧画面
  // 2: セール情報管理画面
  // 3: セール速報画面
  // 4: 商品追加画面
  // 5: 設定画面
  late final List<Widget> _pages = [
    const HomePage(),
    const InventoryPage(),
    const PriceListPage(),
    const SaleListPage(),
    const AddInventoryPage(),
    SettingsPage(
      categories: const [],
      onChanged: (_) {},
      onLocaleChanged: (l) =>
          context.findAncestorStateOfType<MyAppState>()?.updateLocale(l),
      onConditionChanged: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 画面をインデックスで切り替える
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          // ホーム
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: AppLocalizations.of(context)!.buyList,
          ),
          // 在庫一覧
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2),
            label: AppLocalizations.of(context)!.inventoryList,
          ),
          // セール管理
          BottomNavigationBarItem(
            icon: const Icon(Icons.price_change),
            label: AppLocalizations.of(context)!.priceManagementTitle,
          ),
          // セール速報
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer),
            label: AppLocalizations.of(context)!.saleList,
          ),
          // 商品追加
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box),
            label: AppLocalizations.of(context)!.addItem,
          ),
          // 設定
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
