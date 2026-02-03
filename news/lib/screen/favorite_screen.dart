import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/news_card.dart';
import '../widgets/my_drawer.dart';

class FavoriteScreen extends StatelessWidget {
  static const String routeName = '/favorites';

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final favoriteNews = newsProvider.favoriteItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Yêu Thích'),
      drawer: const MyDrawer(),
      body: favoriteNews.isEmpty
          ? const Center(
              child: Text(
                'Chưa có bài viết yêu thích nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: favoriteNews.length,
              itemBuilder: (ctx, index) {
                final news = favoriteNews[index];
                return NewsCard(
                  imageUrl: news.imageUrl,
                  category: news.category,
                  title: news.title,
                  date: news.date,
                  showFavorite: true,
                  isFavorite: news.isFavorite,
                  onFavoriteTap: () {
                    newsProvider.toggleFavoriteStatus(news.id);
                  },
                );
              },
            ),
    );
  }
}
