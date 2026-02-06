import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

class CategoryItem {
  final Category category;
  final Color color;
  bool isActive;

  CategoryItem({
    required this.category,
    required this.color,
    this.isActive = false,
  });

  String get title => category.name;
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
      // 1. Fetch data from remote API
      final response = await http.get(
        Uri.parse('https://apiforlearning.zendvn.com/api/v2/categories_news'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // 2. Extract items from the 'data' field
        final List<dynamic> data = responseData['data'] ?? [];

        // Convert to Category objects
        final List<Category> apiCategories = data
            .map((item) => Category.fromJson(item))
            .toList();

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

        _categories = apiCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return CategoryItem(
            category: category,
            color: colors[index % colors.length],
            isActive: activeCategories.contains(category.name),
          );
        }).toList();
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
      }
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
