import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../apps/constants/app_colors.dart';
import '../apps/routers/router_name.dart';
import '../models/news.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).initialLoad();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      // Khi vuốt lên (tới cuối danh sách)
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isFetchingMore && !newsProvider.isInitialLoading) {
        newsProvider.loadMore();
      }
    }
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.of(context).pushNamed(RouterName.category, arguments: category);
  }

  void _navigateToDetail(BuildContext context, News news) {
    Navigator.of(context).pushNamed(RouterName.newsDetail, arguments: news);
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
      body: RefreshIndicator(
        onRefresh: () => newsProvider.refresh(),
        color: AppColors.primary,
        child: Skeletonizer(
          enabled: newsProvider.isInitialLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
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
                      .where((n) => n.category == categoryItem.title)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: categoryItem.title,
                        onViewAll: () =>
                            _navigateToCategory(context, categoryItem.title),
                      ),
                      ...categoryNews.map(
                        (news) => NewsCard(
                          imageUrl: news.imageUrl,
                          category: news.category,
                          title: news.title,
                          date: news.date,
                          onTap: () => _navigateToDetail(context, news),
                          showFavorite: true,
                          isFavorite: news.isFavorite,
                          onFavoriteTap: () {
                            newsProvider.toggleFavoriteStatus(news.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Loading indicator when fetching more
                if (newsProvider.isFetchingMore &&
                    !newsProvider.isInitialLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
