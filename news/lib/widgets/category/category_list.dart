import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/news_provider.dart';
import '../../screen/news_detail_screen.dart';
import '../common/news_card.dart';

class CategoryList extends StatelessWidget {
  final String category;

  const CategoryList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final newsItems = newsProvider.items;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final news = newsItems[index];
        return NewsCard(
          imageUrl: news.imageUrl,
          category: news.category,
          title: news.title,
          date: news.date,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(NewsDetailScreen.routeName, arguments: news);
          },
          showFavorite: true,
          isFavorite: news.isFavorite,
          onFavoriteTap: () {
            newsProvider.toggleFavoriteStatus(news.id);
          },
        );
      },
    );
  }
}
