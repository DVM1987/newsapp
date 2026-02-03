import 'package:flutter/material.dart';

import '../models/news.dart';

class NewsProvider with ChangeNotifier {
  final List<News> _items = [
    News(
      id: 'n1',
      imageUrl: 'https://picsum.photos/200/300?random=1',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n2',
      imageUrl: 'https://picsum.photos/200/300?random=2',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n3',
      imageUrl: 'https://picsum.photos/200/300?random=3',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n4',
      imageUrl: 'https://picsum.photos/200/300?random=4',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n5',
      imageUrl: 'https://picsum.photos/200/300?random=5',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
    News(
      id: 'n6',
      imageUrl: 'https://picsum.photos/200/300?random=6',
      category: 'Political',
      title:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
      date: 'Mar.5.2023',
      content:
          'Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of Jordan Expresses Its Condolences To The Government And People Of The Friendly Republic Of Indonesia For The Victims Of',
    ),
  ];

  List<News> get items => [..._items];

  List<News> get favoriteItems =>
      _items.where((newsItem) => newsItem.isFavorite).toList();

  void toggleFavoriteStatus(String id) {
    final newsIndex = _items.indexWhere((news) => news.id == id);
    if (newsIndex >= 0) {
      _items[newsIndex].isFavorite = !_items[newsIndex].isFavorite;
      notifyListeners();
    }
  }
}
