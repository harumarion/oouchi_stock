import 'package:flutter/material.dart';
import 'category_settings_page.dart';
import 'domain/entities/category.dart';

class SettingsPage extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<List<Category>> onChanged;
  const SettingsPage({
    super.key,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('カテゴリ設定'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategorySettingsPage(
                    initial: categories,
                    onChanged: onChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

