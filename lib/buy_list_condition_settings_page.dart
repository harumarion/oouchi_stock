import 'package:flutter/material.dart';
import 'package:oouchi_stock/i18n/app_localizations.dart';
import 'domain/entities/buy_list_condition_settings.dart';

/// 買うべきリスト条件設定画面
class BuyListConditionSettingsPage extends StatefulWidget {
  const BuyListConditionSettingsPage({super.key});

  @override
  State<BuyListConditionSettingsPage> createState() => _BuyListConditionSettingsPageState();
}

class _BuyListConditionSettingsPageState extends State<BuyListConditionSettingsPage> {
  BuyListConditionType _type = BuyListConditionType.threshold;
  double _threshold = 0;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await loadBuyListConditionSettings();
    setState(() {
      _type = settings.type;
      _threshold = settings.threshold;
      _days = settings.days;
    });
  }

  Future<void> _save() async {
    await saveBuyListConditionSettings(
      BuyListConditionSettings(type: _type, threshold: _threshold, days: _days),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.buyListConditionSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.threshold,
            groupValue: _type,
            title: Text(loc.thresholdCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.thresholdLabel),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(text: _threshold.toString()),
            onChanged: (v) => _threshold = double.tryParse(v) ?? _threshold,
          ),
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.days,
            groupValue: _type,
            title: Text(loc.daysCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          TextField(
            decoration: InputDecoration(labelText: loc.daysLabel),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: _days.toString()),
            onChanged: (v) => _days = int.tryParse(v) ?? _days,
          ),
          RadioListTile<BuyListConditionType>(
            value: BuyListConditionType.or,
            groupValue: _type,
            title: Text(loc.orCondition),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _save();
              if (mounted) Navigator.pop(context, true);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }
}
