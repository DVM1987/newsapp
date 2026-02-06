import 'package:flutter/material.dart';

import '../models/news.dart';

class NewsProvider with ChangeNotifier {
  static final List<News> _sampleData = [
    News(
      id: 'n1',
      imageUrl: 'https://picsum.photos/200/300?random=1',
      category: 'Thể Thao',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n2',
      imageUrl: 'https://picsum.photos/200/300?random=2',
      category: 'Thể Thao',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n3',
      imageUrl: 'https://picsum.photos/200/300?random=3',
      category: 'Thể Thao',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n4',
      imageUrl: 'https://picsum.photos/200/300?random=4',
      category: 'Thể Thao',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n5',
      imageUrl: 'https://picsum.photos/200/300?random=5',
      category: 'Thời Sự',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n6',
      imageUrl: 'https://picsum.photos/200/300?random=6',
      category: 'Thời Sự',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
  ];

  final List<News> _items = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _isInitialLoading = false;

  bool _isCategoryLoading = false;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get isInitialLoading => _isInitialLoading;
  bool get isCategoryLoading => _isCategoryLoading;

  List<News> get items => [..._items];

  List<News> get dummyItems => List.generate(
    6,
    (index) => News(
      id: 'dummy$index',
      imageUrl: '',
      category: 'Category placeholder',
      title: 'This is a dummy title that should be long enough to occupy lines',
      date: 'Date placeholder',
      content: '',
    ),
  );

  List<News> get favoriteItems =>
      _items.where((newsItem) => newsItem.isFavorite).toList();

  Future<void> initialLoad() async {
    if (_items.isNotEmpty) return;
    _isInitialLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _items.addAll(_sampleData);

    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> loadCategory(String category) async {
    _isCategoryLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isCategoryLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Add a new item at the beginning
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _items.insert(
      0,
      News(
        id: id,
        imageUrl: 'https://picsum.photos/200/300?random=$id',
        category: 'Thời Sự',
        title: '[New] Jordan Expresses Its Condolences...',
        date: 'Just now',
        content: 'This is a new item from refresh.',
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Add some duplicate items to simulate more data
    final newItems = _sampleData.take(2).map((item) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      return News(
        id: id,
        imageUrl: item.imageUrl,
        category: item.category,
        title: '[More] ${item.title}',
        date: item.date,
        content: item.content,
      );
    }).toList();

    _items.addAll(newItems);

    _isFetchingMore = false;
    notifyListeners();
  }

  void toggleFavoriteStatus(String id) {
    final newsIndex = _items.indexWhere((news) => news.id == id);
    if (newsIndex >= 0) {
      _items[newsIndex].isFavorite = !_items[newsIndex].isFavorite;
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
