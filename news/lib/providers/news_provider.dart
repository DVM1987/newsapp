import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';
import '../services/article_service.dart';

class NewsProvider with ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  String? _currentUserId;

  String get _favoritesKey => _currentUserId == null
      ? 'favorite_articles_guest'
      : 'favorite_articles_$_currentUserId';

  // Storage for Home Screen (small subsets)
  final Map<int, List<Article>> _homeArticles = {};

  // Storage for Category Screens (paginated lists)
  final Map<int, List<Article>> _categoryContent = {};
  // Track pagination per category
  final Map<int, int> _categoryPages = {};

  // Persistence: Store favorite articles by ID
  Map<int, Article> _favoriteArticles = {};

  // Current view state
  final bool _isLoading = false;
  final Set<int> _loadingMoreCategories = {};
  bool _isInitialLoading = false;
  bool _isCategoryLoading = false;
  int? _currentCategoryId;

  // Error handling
  final Map<int, String?> _categoryErrorMessages = {};
  String? _initialLoadError;
  List<Article> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  NewsProvider() {
    _loadFavoritesFromPrefs();
  }

  bool get isLoading => _isLoading;
  bool isFetchingMore(int categoryId) =>
      _loadingMoreCategories.contains(categoryId);

  bool get isInitialLoading => _isInitialLoading;
  bool get isCategoryLoading => _isCategoryLoading;

  String? get initialLoadError => _initialLoadError;
  String? getCategoryError(int categoryId) =>
      _categoryErrorMessages[categoryId];

  List<Article> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  Map<int, List<Article>> get homeArticles => _homeArticles;

  List<Article> get favoriteItems => _favoriteArticles.values.toList();

  bool isFavorite(int id) {
    if (_favoriteArticles.isEmpty) return false;
    return _favoriteArticles.containsKey(id);
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

  Future<void> setUserId(String? userId) async {
    // If switching from one user to another or logout
    if (_currentUserId != userId) {
      _currentUserId = userId;

      if (_currentUserId != null) {
        // Login: Load specific favorites for this user
        await _loadFavoritesFromPrefs();
      } else {
        // Logout: Clear memory only. Do NOT clear disk here if we want to separate logic.
        // But clearAllFavorites does clear disk.
        // When logging out, we just want to clear memory.
        _favoriteArticles = {};
        _homeArticles.clear();
        _categoryContent.clear();
        _searchResults.clear();
        _syncFavoritesWithLoadedArticles();
        notifyListeners();
      }
    }
  }

  // --- Persistence Logic ---

  Future<void> _loadFavoritesFromPrefs() async {
    try {
      // Guest: empty favorites initially.
      // If we want guest favorites, remove this check.
      // But prompt implies strictly user data.
      if (_currentUserId == null) {
        _favoriteArticles = {};
        notifyListeners();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _favoritesKey; // uses _currentUserId
      print('NEWS_PROVIDER: Loading favorites for key: $key');

      final favoritesJson = prefs.getStringList(key);
      print('NEWS_PROVIDER: Loaded json list length: ${favoritesJson?.length}');

      if (favoritesJson != null) {
        _favoriteArticles = {
          for (var item in favoritesJson)
            Article.fromJson(json.decode(item)).id: Article.fromJson(
              json.decode(item),
            ),
        };
      } else {
        _favoriteArticles = {};
      }

      _syncFavoritesWithLoadedArticles();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavoritesToPrefs() async {
    try {
      if (_currentUserId == null) {
        print('NEWS_PROVIDER: Skipping save (no user id)');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _favoritesKey;
      print('NEWS_PROVIDER: Saving favorites to key: $key');

      if (_favoriteArticles.isEmpty) {
        await prefs.remove(key);
        print('NEWS_PROVIDER: Removed key (empty list)');
      } else {
        final favoritesJson = _favoriteArticles.values
            .map((article) => json.encode(article.toJson()))
            .toList();
        await prefs.setStringList(key, favoritesJson);
        print('NEWS_PROVIDER: Saved ${favoritesJson.length} items');
      }
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void _syncFavoritesWithLoadedArticles() {
    // Update isFavorite flag on all currently loaded objects
    void updateList(List<Article> list) {
      for (var article in list) {
        article.isFavorite = _favoriteArticles.containsKey(article.id);
      }
    }

    _homeArticles.values.forEach(updateList);
    _categoryContent.values.forEach(updateList);
    updateList(_searchResults);
  }

  // --- Data Loading Logic ---

  Future<void> initialLoad(List<int> activeCategoryIds) async {
    _isInitialLoading = true;
    _initialLoadError = null;
    notifyListeners();

    try {
      _homeArticles.clear();
      await Future.wait(
        activeCategoryIds.map((id) async {
          try {
            final articles = await _articleService.fetchArticles(
              categoryId: id,
              limit: 4,
            );

            // Mark favorites
            for (var a in articles) {
              a.isFavorite = _favoriteArticles.containsKey(a.id);
            }
            _homeArticles[id] = articles;
          } catch (e) {
            debugPrint('Error loading articles for category $id: $e');
            // We don't fail the whole initialLoad if one category fails,
            // but we could mark it. For now, let's just log.
          }
        }),
      );

      if (_homeArticles.isEmpty && activeCategoryIds.isNotEmpty) {
        _initialLoadError =
            "Không thể tải dữ liệu. Vui lòng kiểm tra kết nối hoặc thử lại sau.";
      }
    } catch (e) {
      debugPrint('Error in initialLoad: $e');
      _initialLoadError = "Có lỗi xảy ra khi tải dữ liệu: $e";
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategory(int categoryId) async {
    _isCategoryLoading = true;
    _currentCategoryId = categoryId;
    _categoryErrorMessages[categoryId] = null;
    notifyListeners();

    try {
      _categoryPages[categoryId] = 1;
      final articles = await _articleService.fetchArticles(
        categoryId: categoryId,
        page: 1,
        limit: 10,
      );

      if (articles.isEmpty) {
        _categoryErrorMessages[categoryId] =
            "Không có bài viết nào trong danh mục này.";
      } else {
        // Mark favorites
        for (var a in articles) {
          a.isFavorite = _favoriteArticles.containsKey(a.id);
        }
        _categoryContent[categoryId] = articles;
      }
    } catch (e) {
      debugPrint('Error in loadCategory: $e');
      _categoryErrorMessages[categoryId] = "Lỗi khi tải bài viết: $e";
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int categoryId) async {
    await loadCategory(categoryId);
  }

  Future<void> loadMore(int categoryId) async {
    if (_loadingMoreCategories.contains(categoryId)) return;
    _loadingMoreCategories.add(categoryId);
    // Clear previous error for "load more" if any?
    // Usually load more errors are shown as a snackbar or at the bottom.
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
        // Mark favorites
        for (var a in articles) {
          a.isFavorite = _favoriteArticles.containsKey(a.id);
        }
        final currentList = _categoryContent[categoryId] ?? [];
        _categoryContent[categoryId] = [...currentList, ...articles];
        _categoryPages[categoryId] = nextPage;
      }
    } catch (e) {
      debugPrint('Error in loadMore: $e');
      // For load more, we might just want to show a small error or ignore it for now
      // but let's record it anyway.
      _categoryErrorMessages[categoryId] = "Lỗi khi tải thêm bài viết: $e";
    } finally {
      _loadingMoreCategories.remove(categoryId);
      notifyListeners();
    }
  }

  // --- Favorite Management ---

  void toggleFavoriteStatus(int id, {Article? article}) {
    if (_favoriteArticles.containsKey(id)) {
      _favoriteArticles.remove(id);
    } else {
      Article? foundArticle = article;

      if (foundArticle == null) {
        // Search in home articles
        for (var list in _homeArticles.values) {
          final index = list.indexWhere((a) => a.id == id);
          if (index != -1) {
            foundArticle = list[index];
            break;
          }
        }
      }

      // Search in category content if not found
      if (foundArticle == null) {
        for (var list in _categoryContent.values) {
          final index = list.indexWhere((a) => a.id == id);
          if (index != -1) {
            foundArticle = list[index];
            break;
          }
        }
      }

      if (foundArticle != null) {
        final favoriteCopy = foundArticle.copyWith(isFavorite: true);
        _favoriteArticles[id] = favoriteCopy;
      }
    }
    _syncFavoritesWithLoadedArticles();
    _saveFavoritesToPrefs();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    _isSearching = false;
    notifyListeners();
  }

  String _removeDiacritics(String str) {
    const withDia =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDia =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      // Get more candidates to filter better on client side
      final results = await _articleService.searchArticles(query, limit: 100);

      final qLower = query.toLowerCase().trim();
      final qNoSign = _removeDiacritics(qLower);
      final hasSigns = qLower != qNoSign;

      _searchResults = results.where((article) {
        final title = article.title.toLowerCase();

        if (hasSigns) {
          // Strict search in title only
          return title.contains(qLower);
        } else {
          // No signs: fuzzy sign removal search in title only
          final titleNoSign = _removeDiacritics(title);
          return titleNoSign.contains(qNoSign);
        }
      }).toList();

      // Final Sorting: Prioritize Title matches and Exact matches
      _searchResults.sort((a, b) {
        int score(Article art) {
          final t = art.title.toLowerCase();
          int s = 0;
          if (t.contains(qLower)) s += 10;
          if (t.startsWith(qLower)) s += 5;
          if (hasSigns) {
            if (t == qLower) s += 20;
          } else {
            if (_removeDiacritics(t) == qNoSign) s += 20;
          }
          return s;
        }

        return score(b).compareTo(score(a));
      });

      // Mark favorites
      for (var a in _searchResults) {
        a.isFavorite = _favoriteArticles.containsKey(a.id);
      }

      if (_searchResults.isEmpty) {
        _searchError = "Tìm không ra hoặc không tồn tại.";
      }
    } catch (e) {
      debugPrint('Error in search: $e');
      _searchError = "Lỗi khi tìm kiếm: $e";
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> clearAllFavorites() async {
    // 1. Clear internal map immediately
    _favoriteArticles = {};

    // 2. Sync this change to all currently loaded articles (sets isFavorite = false)
    _syncFavoritesWithLoadedArticles();

    // 3. Clear data lists to ensure UI rebuilds with empty/loading state if needed
    _homeArticles.clear();
    _categoryContent.clear();
    _searchResults.clear();

    // 4. Notify listeners so UI updates immediately (hearts turn white)
    notifyListeners();

    // 5. Persist the empty state
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      debugPrint('Error clearing favorites pref: $e');
    }
  }
}
