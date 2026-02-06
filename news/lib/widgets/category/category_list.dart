import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../apps/constants/app_colors.dart';
import '../../apps/routers/router_name.dart';
import '../../providers/news_provider.dart';
import '../common/news_card.dart';

class CategoryList extends StatefulWidget {
  final String category;

  const CategoryList({super.key, required this.category});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(
        context,
        listen: false,
      ).loadCategory(widget.category);
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
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (!newsProvider.isFetchingMore && !newsProvider.isCategoryLoading) {
        newsProvider.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    final newsItems = newsProvider.isCategoryLoading
        ? newsProvider.dummyItems
        : newsProvider.items
              .where((item) => item.category == widget.category)
              .toList();

    return RefreshIndicator(
      onRefresh: () => newsProvider.refresh(),
      color: AppColors.primary,
      child: Skeletonizer(
        enabled: newsProvider.isCategoryLoading,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8),
          itemCount: newsItems.length + (newsProvider.isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == newsItems.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            final news = newsItems[index];
            return NewsCard(
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
            );
          },
        ),
      ),
    );
  }
}
