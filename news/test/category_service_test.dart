import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news/models/category.dart';
import 'package:news/services/category_service.dart';

void main() {
  group('CategoryService', () {
    const mockCategoriesJson = {
      'status': 'success',
      'data': [
        {
          'id': 1,
          'name': 'Sports',
          'slug': 'sports',
          'link': 'http://example.com',
          'articles_count': 10,
        },
        {
          'id': 2,
          'name': 'Tech',
          'slug': 'tech',
          'link': 'http://example.com/tech',
          'articles_count': 5,
        },
      ],
    };

    test(
      'fetchCategories returns a list of categories when the call completes successfully',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(json.encode(mockCategoriesJson), 200);
        });

        final categoryService = CategoryService(client: mockClient);
        final categories = await categoryService.fetchCategories();

        expect(categories, isA<List<Category>>());
        expect(categories.length, 2);
        expect(categories[0].name, 'Sports');
        expect(categories[1].name, 'Tech');
      },
    );

    test(
      'fetchCategories throws an exception when the http call completes with an error',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final categoryService = CategoryService(client: mockClient);

        expect(categoryService.fetchCategories(), throwsException);
      },
    );

    test(
      'fetchCategories throws an exception when the http call fails due to network error',
      () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Network Error');
        });

        final categoryService = CategoryService(client: mockClient);

        expect(categoryService.fetchCategories(), throwsException);
      },
    );
  });
}
