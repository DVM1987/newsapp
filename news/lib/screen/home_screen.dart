import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../apps/routers/router_name.dart';
import '../models/article.dart';
import '../providers/auth_provider.dart';
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
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  bool? _wasLoggedIn;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final authProvider = Provider.of<AuthProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Reset data initialization if user logs in or out
    // Reset data initialization if user logs in or out
    if (_wasLoggedIn != null && _wasLoggedIn != authProvider.isLoggedIn) {
      _isDataInitialized = false;
      // Close search if logging out
      if (!authProvider.isLoggedIn) {
        _isSearchOpen = false;
        _searchController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          newsProvider.clearSearch();
        });
      }
    }
    _wasLoggedIn = authProvider.isLoggedIn;

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
      appBar: CustomAppBar(
        title: "Trang chủ",
        isSearch: _isSearchOpen,
        searchController: _searchController,
        onSearchToggle: () {
          setState(() {
            _isSearchOpen = !_isSearchOpen;
            if (!_isSearchOpen) {
              _searchController.clear();
              newsProvider.clearSearch();
            }
          });
        },
        onSearchChanged: (value) {
          newsProvider.search(value);
        },
      ),
      body: Skeletonizer(
        enabled: newsProvider.isInitialLoading || settingsProvider.isLoading,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (_isSearchOpen)
                _buildSearchResults(context, newsProvider)
              else ...[
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
                if (newsProvider.initialLoadError != null &&
                    !newsProvider.isInitialLoading)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            newsProvider.initialLoadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final activeIds = settingsProvider.categories
                                  .where((c) => c.isActive)
                                  .map((c) => c.id)
                                  .toList();
                              newsProvider.initialLoad(activeIds);
                            },
                            child: const Text("Thử lại"),
                          ),
                        ],
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
                      if (categoryNews.isEmpty &&
                          !newsProvider.isInitialLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No articles found"),
                        ),
                      ...categoryNews.map(
                        (article) => NewsCard(
                          imageUrl: article.thumb,
                          category: categoryItem.title,
                          title: article.title,
                          date: article.publishDate,
                          onTap: () => _navigateToDetail(context, article),
                          showFavorite: true,
                          isFavorite: newsProvider.isFavorite(article.id),
                          onFavoriteTap: () {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (!authProvider.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng đăng nhập để sử dụng tính năng này',
                                  ),
                                ),
                              );
                              return;
                            }
                            newsProvider.toggleFavoriteStatus(
                              article.id,
                              article: article,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, NewsProvider newsProvider) {
    if (newsProvider.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (newsProvider.searchError != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            newsProvider.searchError!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final results = newsProvider.searchResults;

    if (results.isEmpty && _searchController.text.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("Tìm không ra hoặc không tồn tại.")),
      );
    }

    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("Nhập từ khóa để tìm kiếm bài viết.")),
      );
    }

    return Column(
      children: results
          .map(
            (article) => NewsCard(
              imageUrl: article.thumb,
              category: "Kết quả tìm kiếm",
              title: article.title,
              date: article.publishDate,
              onTap: () => _navigateToDetail(context, article),
              showFavorite: true,
              isFavorite: newsProvider.isFavorite(article.id),
              onFavoriteTap: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                if (!authProvider.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Vui lòng đăng nhập để sử dụng tính năng này',
                      ),
                    ),
                  );
                  return;
                }
                newsProvider.toggleFavoriteStatus(article.id, article: article);
              },
            ),
          )
          .toList(),
    );
  }
}
