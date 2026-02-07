import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/shared_prefs_helper.dart';

class CategoryItem {
  final int id;
  final String title;
  final Category category;
  final Color color;
  bool isActive;

  CategoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    this.isActive = false,
  });
}

class SettingsProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
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
      // 1. Fetch data from Service
      final apiCategories = await _categoryService.fetchCategories();

      // 2. Load active states from SharedPreferences
      List<String> activeCategoryIds =
          await SharedPrefsHelper.getActiveCategoryIds();
      List<String> activeCategoryNames =
          await SharedPrefsHelper.getActiveCategoryNames();

      // Default categories if nothing is saved
      if (activeCategoryIds.isEmpty && activeCategoryNames.isEmpty) {
        activeCategoryNames = ['Thể Thao', 'Thế Giới', 'Pháp Luật'];
        // We'll save these defaults too
        final defaultCategories = apiCategories
            .where((c) => activeCategoryNames.contains(c.name))
            .toList();
        final defaultIds = defaultCategories.map((c) => c.id).toList();
        final defaultNames = defaultCategories.map((c) => c.name).toList();
        await SharedPrefsHelper.saveActiveCategories(defaultIds, defaultNames);

        activeCategoryIds = defaultIds.map((id) => id.toString()).toList();
        activeCategoryNames = defaultNames;
      }

      // 3. Create CategoryItem list with colors
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
          id: category.id,
          title: category.name,
          category: category,
          color: colors[index % colors.length],
          isActive:
              activeCategoryIds.contains(category.id.toString()) ||
              activeCategoryNames.contains(category.name),
        );
      }).toList();

      // 4. Sort: Active categories first
      _sortCategories();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortCategories() {
    _categories.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return 0;
    });
  }

  Future<void> toggleCategory(int id) async {
    final index = _categories.indexWhere((item) => item.id == id);
    if (index != -1) {
      _categories[index].isActive = !_categories[index].isActive;

      // Re-sort after toggle
      _sortCategories();

      // Save to SharedPreferences
      final activeCategories = _categories.where((item) => item.isActive);
      final activeIds = activeCategories
          .map((item) => item.category.id)
          .toList();
      final activeNames = activeCategories
          .map((item) => item.category.name)
          .toList();

      await SharedPrefsHelper.saveActiveCategories(activeIds, activeNames);

      notifyListeners();
    }
  }
}
