import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late Map<String, String> _strings;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ja')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    final data = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    final Map<String, dynamic> map = json.decode(data);
    _strings = map.map((k, v) => MapEntry(k, v.toString()));
    return true;
  }

  String _get(String key) => _strings[key] ?? key;

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
  String loadError(String err) => (_strings['loadError'] ?? 'loadError {err}').replaceFirst('{err}', err);
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
  String totalVolume(String v) => (_strings['totalVolume'] ?? 'totalVolume {value}').replaceFirst('{value}', v);
  String unitPrice(String v) => (_strings['unitPrice'] ?? 'unitPrice {value}').replaceFirst('{value}', v);
  String get totalVolumeLabel => _get('totalVolumeLabel');
  String get unitPriceLabel => _get('unitPriceLabel');
  String checkedDate(String d) => (_strings['checkedDate'] ?? 'checked {date}').replaceFirst('{date}', d);
  String priceSummary({required String count, required String unitStr, required String volume, required String total, required String price, required String shop, required String unitPrice}) {
    var template = _strings['priceSummary'] ?? '';
    return template
        .replaceFirst('{count}', count)
        .replaceFirst('{unit}', unitStr)
        .replaceFirst('{volume}', volume)
        .replaceFirst('{total}', total)
        .replaceFirst('{price}', price)
        .replaceFirst('{shop}', shop)
        .replaceFirst('{unitPrice}', unitPrice);
  }
  String get categorySettings => _get('categorySettings');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
