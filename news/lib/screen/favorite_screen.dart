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
    final favoriteArticles = newsProvider.favoriteItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Yêu Thích',
        actions: [
          if (favoriteArticles.isNotEmpty)
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
      body: favoriteArticles.isEmpty
          ? const Center(
              child: Text(
                'Chưa có bài viết yêu thích nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: favoriteArticles.length,
              itemBuilder: (ctx, index) {
                final article = favoriteArticles[index];
                return Dismissible(
                  key: ValueKey(article.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    newsProvider.toggleFavoriteStatus(article.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa khỏi danh sách yêu thích'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: NewsCard(
                    imageUrl: article.thumb,
                    category: article.category?.name ?? '',
                    title: article.title,
                    date: article.publishDate,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(RouterName.newsDetail, arguments: article);
                    },
                    showFavorite: true,
                    isFavorite: article.isFavorite,
                    onFavoriteTap: () {
                      newsProvider.toggleFavoriteStatus(article.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
