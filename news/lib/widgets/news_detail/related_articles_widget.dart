import 'package:flutter/material.dart';

import '../../apps/routers/router_name.dart';
import '../../models/article.dart';
import '../../services/article_service.dart';
import '../common/news_card.dart';

class RelatedArticlesWidget extends StatefulWidget {
  final int categoryId;
  final int currentArticleId;

  const RelatedArticlesWidget({
    super.key,
    required this.categoryId,
    required this.currentArticleId,
  });

  @override
  State<RelatedArticlesWidget> createState() => _RelatedArticlesWidgetState();
}

class _RelatedArticlesWidgetState extends State<RelatedArticlesWidget> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRelatedArticles();
  }

  Future<void> _fetchRelatedArticles() async {
    try {
      final articles = await _articleService.fetchArticles(
        categoryId: widget.categoryId,
        limit: 12, // Fetch enough for a few slides
      );
      if (mounted) {
        setState(() {
          _articles = articles
              .where((a) => a.id != widget.currentArticleId)
              .toList();

          // Sort by publishDate descending to ensure latest articles are shown
          _articles.sort((a, b) {
            final dateA = DateTime.tryParse(a.publishDate) ?? DateTime(1970);
            final dateB = DateTime.tryParse(b.publishDate) ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching related articles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_articles.isEmpty) {
      return const SizedBox.shrink();
    }

    const int itemsPerPage = 4;
    final int pageCount = (_articles.length / itemsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Related Articles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 600, // Approximate height for 4 items
          child: PageView.builder(
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex = (startIndex + itemsPerPage < _articles.length)
                  ? startIndex + itemsPerPage
                  : _articles.length;
              final pageArticles = _articles.sublist(startIndex, endIndex);

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: pageArticles.map((article) {
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
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
