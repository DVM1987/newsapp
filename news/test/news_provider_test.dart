import 'package:flutter_test/flutter_test.dart';
import 'package:news/providers/news_provider.dart';

void main() {
  group('NewsProvider', () {
    test('initial items list is not empty', () {
      final provider = NewsProvider();
      expect(provider.items.isNotEmpty, true);
    });

    test('toggleFavoriteStatus updates isFavorite and favoriteItems list', () {
      final provider = NewsProvider();
      final newsId = provider.items[0].id;
      final initialFavoriteStatus = provider.items[0].isFavorite;

      provider.toggleFavoriteStatus(newsId);

      expect(provider.items[0].isFavorite, !initialFavoriteStatus);
      if (initialFavoriteStatus) {
        expect(provider.favoriteItems.any((item) => item.id == newsId), false);
      } else {
        expect(provider.favoriteItems.any((item) => item.id == newsId), true);
      }
    });

    test('favoriteItems correctly filters items', () {
      final provider = NewsProvider();
      // Initially all should be false if not set in mock data
      for (var item in provider.items) {
        item.isFavorite = false;
      }

      expect(provider.favoriteItems.length, 0);

      provider.toggleFavoriteStatus(provider.items[0].id);
      expect(provider.favoriteItems.length, 1);
      expect(provider.favoriteItems[0].id, provider.items[0].id);
    });
  });
}
