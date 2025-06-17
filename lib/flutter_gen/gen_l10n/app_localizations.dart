import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('ja')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'appTitle': "Oouchi Stock",
    'addCategory': "Add Category",
    'addItem': "Add Item",
    'priceManagement': "Price Management",
    'settings': "Settings",
    'categoryAddTitle': "Add Category",
    'categoryEditTitle': "Edit Category",
    'categoryName': "Category name",
    'categorySettingsTitle': "Category Settings",
    'itemTypeAddTitle': "Add Item Type",
    'itemTypeEditTitle': "Edit Item Type",
    'itemTypeSettingsTitle': "Item Type Settings",
    'itemTypeSettings': "Item Type Settings",
    'save': "Save",
    'saved': "Saved",
    'saveFailed': "Failed to save",
    'delete': "Delete",
    'deleted': "Deleted",
    'deleteFailed': "Failed to delete",
    'itemNameRequired': "Item name is required",
    'required': "Required",
    'inventoryAddTitle': "Add Item",
    'inventoryEditTitle': "Edit Item",
    'category': "Category",
    'itemName': "Item name",
    'itemType': "Item type",
    'quantity': "Quantity",
    'unit': "Unit",
    'memo': "Memo",
    'memoOptional': "Memo (optional)",
    'loadError': "Load error: {err}",
    'cancel': "Cancel",
    'ok': "OK",
    'usedAmount': "Used amount",
    'boughtAmount': "Bought amount",
    'stockAmount': "Current stock",
    'updateFailed': "Update failed",
    'predictLabel': "Prediction:",
    'calculating': "Calculating...",
    'history': "History",
    'priceAddTitle': "Add Price",
    'priceManagementTitle': "Price Management",
    'count': "Count",
    'volume': "Volume",
    'price': "Price",
    'shop': "Shop",
    'totalVolume': "Total volume: {value}",
    'unitPrice': "Unit price: {value}",
    'checkedDate': "Checked: {date}",
    'categorySettings': "Category Settings",
    'priceSummary': "Count:{count} {unit} Volume:{volume} Total:{total} Price:{price} Shop:{shop} Unit price:{unitPrice}",
    'totalVolumeLabel': "Total",
    'unitPriceLabel': "Unit price",
    'buyList': "Buy List",
    'buyListTitle': "Items to Buy",
    'noBuyItems': "No items to buy",
    'buyListNotificationTitle': "Shopping Reminder",
    'buyListNotificationBody': "Check items to buy",
  },
  'ja': {
    'appTitle': "おうちストック",
    'addCategory': "カテゴリを追加",
    'addItem': "商品を追加",
    'priceManagement': "値段管理",
    'settings': "設定",
    'categoryAddTitle': "カテゴリ追加",
    'categoryEditTitle': "カテゴリ編集",
    'categoryName': "カテゴリ名",
    'categorySettingsTitle': "カテゴリ設定",
    'itemTypeAddTitle': "品種追加",
    'itemTypeEditTitle': "品種編集",
    'itemTypeSettingsTitle': "品種設定",
    'itemTypeSettings': "品種設定",
    'save': "保存",
    'saved': "保存しました",
    'saveFailed': "保存に失敗しました",
    'delete': "削除",
    'deleted': "削除しました",
    'deleteFailed': "削除に失敗しました",
    'itemNameRequired': "商品名は必須です",
    'required': "必須項目です",
    'inventoryAddTitle': "商品を追加",
    'inventoryEditTitle': "商品編集",
    'category': "カテゴリ",
    'itemName': "商品名",
    'itemType': "品種",
    'quantity': "数量",
    'unit': "単位",
    'memo': "メモ",
    'memoOptional': "メモ（任意）",
    'loadError': "読み込みエラー: {err}",
    'cancel': "キャンセル",
    'ok': "OK",
    'usedAmount': "使った量",
    'boughtAmount': "買った量",
    'stockAmount': "現在の在庫",
    'updateFailed': "更新に失敗しました",
    'predictLabel': "予測:",
    'calculating': "計算中...",
    'history': "履歴",
    'priceAddTitle': "値段管理追加",
    'priceManagementTitle': "値段管理",
    'count': "数",
    'volume': "容量",
    'price': "値段",
    'shop': "購入元",
    'totalVolume': "合計容量: {value}",
    'unitPrice': "単価: {value}",
    'checkedDate': "確認日: {date}",
    'categorySettings': "カテゴリ設定",
    'priceSummary': "数:{count} {unit} 容量:{volume} 合計:{total} 値段:{price} 購入元:{shop} 単価:{unitPrice}",
    'totalVolumeLabel': "合計",
    'unitPriceLabel': "単価",
    'buyList': "買い物リスト",
    'buyListTitle': "買うべきリスト",
    'noBuyItems': "買うものはありません",
    'buyListNotificationTitle': "買い物リマインダー",
    'buyListNotificationBody': "買うべき在庫を確認してください",
  },
  };

  String _get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  String loadError(Object err) => _get('loadError').replaceAll('{err}', err.toString());
  String totalVolume(String value) => _get('totalVolume').replaceAll('{value}', value);
  String unitPrice(String value) => _get('unitPrice').replaceAll('{value}', value);
  String checkedDate(String date) => _get('checkedDate').replaceAll('{date}', date);
  String priceSummary({required String count, required String unit, required String volume, required String total, required String price, required String shop, required String unitPriceValue}) {
    return _get('priceSummary')
        .replaceAll('{count}', count)
        .replaceAll('{unit}', unit)
        .replaceAll('{volume}', volume)
        .replaceAll('{total}', total)
        .replaceAll('{price}', price)
        .replaceAll('{shop}', shop)
        .replaceAll('{unitPrice}', unitPriceValue);
  }

  String get appTitle => _get('appTitle');
  String get addCategory => _get('addCategory');
  String get addItem => _get('addItem');
  String get priceManagement => _get('priceManagement');
  String get settings => _get('settings');
  String get categoryAddTitle => _get('categoryAddTitle');
  String get categoryEditTitle => _get('categoryEditTitle');
  String get categoryName => _get('categoryName');
  String get categorySettingsTitle => _get('categorySettingsTitle');
  String get itemTypeAddTitle => _get('itemTypeAddTitle');
  String get itemTypeEditTitle => _get('itemTypeEditTitle');
  String get itemTypeSettingsTitle => _get('itemTypeSettingsTitle');
  String get itemTypeSettings => _get('itemTypeSettings');
  String get save => _get('save');
  String get saved => _get('saved');
  String get saveFailed => _get('saveFailed');
  String get delete => _get('delete');
  String get deleted => _get('deleted');
  String get deleteFailed => _get('deleteFailed');
  String get itemNameRequired => _get('itemNameRequired');
  String get required => _get('required');
  String get inventoryAddTitle => _get('inventoryAddTitle');
  String get inventoryEditTitle => _get('inventoryEditTitle');
  String get category => _get('category');
  String get itemName => _get('itemName');
  String get itemType => _get('itemType');
  String get quantity => _get('quantity');
  String get unit => _get('unit');
  String get memo => _get('memo');
  String get memoOptional => _get('memoOptional');
  String get cancel => _get('cancel');
  String get ok => _get('ok');
  String get usedAmount => _get('usedAmount');
  String get boughtAmount => _get('boughtAmount');
  String get stockAmount => _get('stockAmount');
  String get updateFailed => _get('updateFailed');
  String get predictLabel => _get('predictLabel');
  String get calculating => _get('calculating');
  String get history => _get('history');
  String get priceAddTitle => _get('priceAddTitle');
  String get priceManagementTitle => _get('priceManagementTitle');
  String get count => _get('count');
  String get volume => _get('volume');
  String get price => _get('price');
  String get shop => _get('shop');
  String get categorySettings => _get('categorySettings');
  String get totalVolumeLabel => _get('totalVolumeLabel');
  String get unitPriceLabel => _get('unitPriceLabel');
  String get buyList => _get('buyList');
  String get buyListTitle => _get('buyListTitle');
  String get noBuyItems => _get('noBuyItems');
  String get buyListNotificationTitle => _get('buyListNotificationTitle');
  String get buyListNotificationBody => _get('buyListNotificationBody');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
