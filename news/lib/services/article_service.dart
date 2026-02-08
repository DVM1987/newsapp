import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class ArticleService {
  static const String _baseUrl = 'https://apiforlearning.zendvn.com/api/v2';

  Future<List<Article>> fetchArticles({
    int? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url;
      if (categoryId != null) {
        url =
            '$_baseUrl/categories_news/$categoryId/articles?page=$page&limit=$limit';
      } else {
        url = '$_baseUrl/articles?page=$page&limit=$limit';
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
