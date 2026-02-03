import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/news_card.dart';
import '../widgets/common/section_header.dart';
import '../widgets/my_drawer.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.of(
      context,
    ).pushNamed(CategoryScreen.routeName, arguments: category);
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final newsItems = newsProvider.items;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Thể Thao Section
            SectionHeader(
              title: 'Thể Thao',
              onViewAll: () => _navigateToCategory(context, 'Thể Thao'),
            ),
            ...newsItems
                .take(4)
                .map(
                  (news) => NewsCard(
                    imageUrl: news.imageUrl,
                    category: news.category,
                    title: news.title,
                    date: news.date,
                    onTap: () => _navigateToCategory(context, news.category),
                    showFavorite: true,
                    isFavorite: news.isFavorite,
                    onFavoriteTap: () {
                      newsProvider.toggleFavoriteStatus(news.id);
                    },
                  ),
                ),

            const SizedBox(height: 16),

            // Thời Sự Section
            SectionHeader(
              title: 'Thời Sự',
              onViewAll: () => _navigateToCategory(context, 'Thời Sự'),
            ),
            if (newsItems.length > 4)
              NewsCard(
                imageUrl: newsItems[4].imageUrl,
                category: newsItems[4].category,
                title: newsItems[4].title,
                date: newsItems[4].date,
                onTap: () =>
                    _navigateToCategory(context, newsItems[4].category),
                showFavorite: true,
                isFavorite: newsItems[4].isFavorite,
                onFavoriteTap: () {
                  newsProvider.toggleFavoriteStatus(newsItems[4].id);
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
