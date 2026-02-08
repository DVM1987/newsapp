import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/article_service.dart';

class NewsProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();

  // Storage for Home Screen (small subsets)
  final Map<int, List<Article>> _homeArticles = {};

  // Storage for Category Screens (paginated lists)
  final Map<int, List<Article>> _categoryContent = {};
  // Track pagination per category
  final Map<int, int> _categoryPages = {};

  // Current view state
  final bool _isLoading = false;
  // We might need a map for loading states if we want true parallelism,
  // but for now, generally user interacts with one list at a time via scroll.
  // One global lock is okay-ish, or use a set of loading IDs.
  final Set<int> _loadingMoreCategories = {};
  bool _isInitialLoading = false;
  bool _isCategoryLoading = false;
  // int _currentPage = 1; // Removed global page
  int? _currentCategoryId;

  bool get isLoading => _isLoading;
  // bool get isFetchingMore => _isFetchingMore; // Changed to check specific category
  bool isFetchingMore(int categoryId) =>
      _loadingMoreCategories.contains(categoryId);

  bool get isInitialLoading => _isInitialLoading;
  bool get isCategoryLoading => _isCategoryLoading;

  Map<int, List<Article>> get homeArticles => _homeArticles;

  // Legacy getter if needed, or for Favorites
  // We aggregate all known articles for favorites
  List<Article> get favoriteItems {
    final allArticles = <Article>{};
    for (var list in _homeArticles.values) {
      allArticles.addAll(list);
    }
    for (var list in _categoryContent.values) {
      allArticles.addAll(list);
    }
    return allArticles.where((article) => article.isFavorite).toList();
  }

  // Helper to access category content safely
  List<Article> getArticlesForCategory(int categoryId) {
    return _categoryContent[categoryId] ?? [];
  }

  // Items getter for compatibility - returns current category items if set, else empty
  List<Article> get items {
    if (_currentCategoryId != null) {
      return _categoryContent[_currentCategoryId!] ?? [];
    }
    return [];
  }

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

  Future<void> initialLoad(List<int> activeCategoryIds) async {
    _isInitialLoading = true;
    notifyListeners();

    try {
      _homeArticles.clear();
      await Future.wait(
        activeCategoryIds.map((id) async {
          final articles = await _articleService.fetchArticles(
            categoryId: id,
            limit: 4,
          );
          _homeArticles[id] = articles;
        }),
      );
    } catch (e) {
      debugPrint('Error in initialLoad: $e');
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategory(int categoryId) async {
    _isCategoryLoading = true;
    _currentCategoryId = categoryId;
    notifyListeners();

    try {
      _categoryPages[categoryId] = 1;
      final articles = await _articleService.fetchArticles(
        categoryId: categoryId,
        page: 1,
        limit: 10,
      );
      _categoryContent[categoryId] = articles;
    } catch (e) {
      debugPrint('Error in loadCategory: $e');
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int categoryId) async {
    // Just reload category
    await loadCategory(categoryId);
  }

  Future<void> loadMore(int categoryId) async {
    if (_loadingMoreCategories.contains(categoryId)) return;
    _loadingMoreCategories.add(categoryId);
    notifyListeners();

    try {
      final currentPage = _categoryPages[categoryId] ?? 1;
      final nextPage = currentPage + 1;

      final articles = await _articleService.fetchArticles(
        categoryId: categoryId,
        page: nextPage,
        limit: 10,
      );

      if (articles.isNotEmpty) {
        final currentList = _categoryContent[categoryId] ?? [];
        _categoryContent[categoryId] = [...currentList, ...articles];
        _categoryPages[categoryId] = nextPage;
      }
    } catch (e) {
      debugPrint('Error in loadMore: $e');
    } finally {
      _loadingMoreCategories.remove(categoryId);
      notifyListeners();
    }
  }

  void toggleFavoriteStatus(int id) {
    // Helper to toggle in a list
    void toggleInList(List<Article> list) {
      final index = list.indexWhere((i) => i.id == id);
      if (index != -1) {
        // Create a new instance with toggled state to trigger updates if needed,
        // or just mutate. Mutating is easier for sync but effectively we need UI to rebuild.
        // Since we use ChangeNotifier, assuming mutation works if we notify.
        list[index].isFavorite = !list[index].isFavorite;
      }
    }

    _homeArticles.values.forEach(toggleInList);
    _categoryContent.values.forEach(toggleInList);

    notifyListeners();
  }

  void clearAllFavorites() {
    // Helper
    void clearInList(List<Article> list) {
      for (var item in list) {
        item.isFavorite = false;
      }
    }

    _homeArticles.values.forEach(clearInList);
    _categoryContent.values.forEach(clearInList);
    notifyListeners();
  }
}
