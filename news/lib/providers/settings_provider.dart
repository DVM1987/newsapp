import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryItem {
  final String title;
  final Color color;
  bool isActive;

  CategoryItem({
    required this.title,
    required this.color,
    this.isActive = false,
  });
}

class SettingsProvider with ChangeNotifier {
  List<CategoryItem> _categories = [];
  bool _isLoading = true;

  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Read JSON file from assets
      final String jsonString = await rootBundle.loadString('api/API.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      // 2. Extract item names from Postman collection
      final List<dynamic> items = data['item'] ?? [];

      // 3. Load active states from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final List<String> activeCategories =
          prefs.getStringList('active_categories') ?? [];

      // 4. Create CategoryItem list with colors
      final List<Color> colors = [
        const Color(0xFFFB8484),
        const Color(0xFF74BDCB),
        const Color(0xFFFFBD59),
        const Color(0xFF7B61FF),
        const Color(0xFFD470FF),
        const Color(0xFFFFC045),
        const Color(0xFFA5D65A),
        const Color(0xFF8DAAB2),
      ];

      _categories = items.asMap().entries.map((entry) {
        final index = entry.key;
        final name = entry.value['name'] as String;
        return CategoryItem(
          title: name,
          color: colors[index % colors.length],
          isActive: activeCategories.contains(name),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCategory(String title) async {
    final index = _categories.indexWhere((item) => item.title == title);
    if (index != -1) {
      _categories[index].isActive = !_categories[index].isActive;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final activeList = _categories
          .where((item) => item.isActive)
          .map((item) => item.title)
          .toList();
      await prefs.setStringList('active_categories', activeList);

      notifyListeners();
    }
  }
}
