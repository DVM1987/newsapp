import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';

class CategoryService {
  static const String _baseUrl =
      'https://apiforlearning.zendvn.com/api/v2/categories_news';

  final http.Client client;

  CategoryService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await client.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        return data.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
