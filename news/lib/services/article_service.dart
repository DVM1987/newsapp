import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class ArticleService {
  static const String _baseUrl =
      'https://apiforlearning.zendvn.com/api/v2/articles';

  Future<List<Article>> fetchArticles({int? categoryId, int page = 1}) async {
    try {
      String url = '$_baseUrl?page=$page';
      if (categoryId != null) {
        url += '&category_id=$categoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        return data.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }
}
