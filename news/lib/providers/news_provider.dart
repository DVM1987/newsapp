import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/article_service.dart';

class NewsProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  final List<Article> _items = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _isInitialLoading = false;
  bool _isCategoryLoading = false;
  int _currentPage = 1;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get isInitialLoading => _isInitialLoading;
  bool get isCategoryLoading => _isCategoryLoading;

  List<Article> get items => [..._items];

  List<Article> get dummyItems => List.generate(
    6,
    (index) => Article(
      id: index,
      title: 'This is a dummy title that should be long enough to occupy lines',
      description: 'Dummy description',
      slug: 'dummy-$index',
      content: 'Dummy content',
      thumb: '',
      author: 'Author placeholder',
      publishDate: 'Date placeholder',
      status: 1,
      categoryId: 0,
    ),
  );

  List<Article> get favoriteItems =>
      _items.where((article) => article.isFavorite).toList();

  Future<void> initialLoad() async {
    if (_items.isNotEmpty) return;
    _isInitialLoading = true;
    notifyListeners();

    try {
      _currentPage = 1;
      final articles = await _articleService.fetchArticles(page: _currentPage);
      _items.clear();
      _items.addAll(articles);
    } catch (e) {
      debugPrint('Error in initialLoad: $e');
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategory(int categoryId) async {
    _isCategoryLoading = true;
    notifyListeners();

    try {
      await _articleService.fetchArticles(categoryId: categoryId);
      // If we want to replace all items with category items, or just add them?
      // Usually CategoryScreen calls this, so it might need its own provider state or just return the list.
      // For now, let's keep it simple.
    } catch (e) {
      debugPrint('Error in loadCategory: $e');
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPage = 1;
      final articles = await _articleService.fetchArticles(page: _currentPage);
      _items.clear();
      _items.addAll(articles);
    } catch (e) {
      debugPrint('Error in refresh: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final articles = await _articleService.fetchArticles(page: _currentPage);
      _items.addAll(articles);
    } catch (e) {
      debugPrint('Error in loadMore: $e');
      _currentPage--;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void toggleFavoriteStatus(int id) {
    final articleIndex = _items.indexWhere((article) => article.id == id);
    if (articleIndex >= 0) {
      _items[articleIndex].isFavorite = !_items[articleIndex].isFavorite;
      notifyListeners();
    }
  }

  void clearAllFavorites() {
    for (var item in _items) {
      item.isFavorite = false;
    }
    notifyListeners();
  }
}
