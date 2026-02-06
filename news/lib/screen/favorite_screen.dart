import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../apps/routers/router_name.dart';
import '../providers/news_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/news_card.dart';
import '../widgets/my_drawer.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final favoriteNews = newsProvider.favoriteItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Yêu Thích',
        actions: [
          if (favoriteNews.isNotEmpty)
            TextButton(
              onPressed: () {
                newsProvider.clearAllFavorites();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
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
                return Dismissible(
                  key: ValueKey(news.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    newsProvider.toggleFavoriteStatus(news.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa khỏi danh sách yêu thích'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: NewsCard(
                    imageUrl: news.imageUrl,
                    category: news.category,
                    title: news.title,
                    date: news.date,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(RouterName.newsDetail, arguments: news);
                    },
                    showFavorite: true,
                    isFavorite: news.isFavorite,
                    onFavoriteTap: () {
                      newsProvider.toggleFavoriteStatus(news.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
