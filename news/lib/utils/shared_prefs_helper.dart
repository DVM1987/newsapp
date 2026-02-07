import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyActiveCategoryNames = 'active_category_names';
  static const String _keyActiveCategoryIds = 'active_category_ids';

  // Generic methods
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, value);
  }

  static Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  // Specific methods for categories
  static Future<void> saveActiveCategories(
    List<int> ids,
    List<String> names,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyActiveCategoryIds,
      ids.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(_keyActiveCategoryNames, names);
  }

  static Future<Map<String, List<String>>> getActiveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ids': prefs.getStringList(_keyActiveCategoryIds) ?? [],
      'names': prefs.getStringList(_keyActiveCategoryNames) ?? [],
    };
  }

  static Future<List<String>> getActiveCategoryNames() async {
    return await getStringList(_keyActiveCategoryNames);
  }

  static Future<List<String>> getActiveCategoryIds() async {
    return await getStringList(_keyActiveCategoryIds);
  }
}
