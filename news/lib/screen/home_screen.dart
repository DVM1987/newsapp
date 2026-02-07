import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../apps/routers/router_name.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/news_card.dart';
import '../widgets/common/section_header.dart';
import '../widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).initialLoad();
    });
  }

  void _navigateToCategory(BuildContext context, int id, String title) {
    Navigator.of(
      context,
    ).pushNamed(RouterName.category, arguments: {'id': id, 'title': title});
  }

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.of(context).pushNamed(RouterName.newsDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final activeCategories = settingsProvider.categories
        .where((c) => c.isActive)
        .toList();

    final newsItems = newsProvider.isInitialLoading
        ? newsProvider.dummyItems
        : newsProvider.items;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      appBar: const CustomAppBar(),
      body: Skeletonizer(
        enabled: newsProvider.isInitialLoading,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (activeCategories.isEmpty && !newsProvider.isInitialLoading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No categories selected.\nGo to Settings to select categories.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ...activeCategories.map((categoryItem) {
                final categoryNews = newsItems
                    .where((n) => n.categoryId == categoryItem.id)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: categoryItem.title,
                      onViewAll: () => _navigateToCategory(
                        context,
                        categoryItem.id,
                        categoryItem.title,
                      ),
                    ),
                    ...categoryNews.map(
                      (article) => NewsCard(
                        imageUrl: article.thumb,
                        category: article.category?.name ?? '',
                        title: article.title,
                        date: article.publishDate,
                        onTap: () => _navigateToDetail(context, article),
                        showFavorite: true,
                        isFavorite: article.isFavorite,
                        onFavoriteTap: () {
                          newsProvider.toggleFavoriteStatus(article.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
