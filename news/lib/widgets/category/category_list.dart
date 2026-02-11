import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../apps/constants/app_colors.dart';
import '../../apps/routers/router_name.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';
import '../common/news_card.dart';

class CategoryList extends StatefulWidget {
  final String categoryTitle;
  final int categoryId;

  const CategoryList({
    super.key,
    required this.categoryTitle,
    required this.categoryId,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();
  bool? _wasLoggedIn;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(
        context,
        listen: false,
      ).loadCategory(widget.categoryId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    if (_wasLoggedIn != null && _wasLoggedIn != authProvider.isLoggedIn) {
      // Re-fetch category data when login status changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<NewsProvider>(
            context,
            listen: false,
          ).loadCategory(widget.categoryId);
        }
      });
    }
    _wasLoggedIn = authProvider.isLoggedIn;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      // Check if specifically this category is fetching more
      if (!newsProvider.isFetchingMore(widget.categoryId) &&
          !newsProvider.isCategoryLoading) {
        newsProvider.loadMore(widget.categoryId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    // Use specific getter for this category
    final newsItems = newsProvider.isCategoryLoading
        ? newsProvider
              .dummyItems // Fallback to dummy items if loading fresh
        : newsProvider.getArticlesForCategory(widget.categoryId);

    final error = newsProvider.getCategoryError(widget.categoryId);

    if (error != null && !newsProvider.isCategoryLoading && newsItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => newsProvider.loadCategory(widget.categoryId),
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => newsProvider.refresh(widget.categoryId),
      color: AppColors.primary,
      child: Skeletonizer(
        enabled: newsProvider.isCategoryLoading,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8),
          // Check specifically this category
          itemCount:
              newsItems.length +
              (newsProvider.isFetchingMore(widget.categoryId) ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == newsItems.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            final article = newsItems[index];
            return NewsCard(
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
            );
          },
        ),
      ),
    );
  }
}
