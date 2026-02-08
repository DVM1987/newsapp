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
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    // Logic moved to build/didChangeDependencies to wait for settings
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

    // Initial Load Logic depending on Settings
    if (!settingsProvider.isLoading && !_isDataInitialized) {
      final activeIds = settingsProvider.categories
          .where((c) => c.isActive)
          .map((c) => c.id)
          .toList();
      if (activeIds.isNotEmpty) {
        _isDataInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          newsProvider.initialLoad(activeIds);
        });
      }
    }

    final activeCategories = settingsProvider.categories
        .where((c) => c.isActive)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      appBar: const CustomAppBar(),
      body: Skeletonizer(
        enabled: newsProvider.isInitialLoading || settingsProvider.isLoading,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (activeCategories.isEmpty &&
                  !newsProvider.isInitialLoading &&
                  !settingsProvider.isLoading)
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
                // Get articles for this category from the map
                // If loading, use dummy data for skeleton
                final rawArticles = newsProvider.isInitialLoading
                    ? newsProvider
                          .dummyItems // Fallback for skeleton
                    : (newsProvider.homeArticles[categoryItem.id] ?? []);

                // Show fixed number of 4 articles
                final categoryNews = rawArticles.take(4).toList();

                // If not loading and no data, maybe hide section?
                // But user wants to fix specific categories not showing data.
                // If empty list, rendered maps to empty list of widgets.
                // Should at least show header? Yes.

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
                    if (categoryNews.isEmpty && !newsProvider.isInitialLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No articles found"),
                      ),
                    ...categoryNews.map(
                      (article) => NewsCard(
                        imageUrl: article.thumb,
                        category: categoryItem
                            .title, // Use category title from settings as it matches section
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
