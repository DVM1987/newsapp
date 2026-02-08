import 'package:flutter/material.dart';

import '../models/article.dart';
import '../widgets/news_detail/news_detail_content.dart';
import '../widgets/news_detail/news_detail_header.dart';
import '../widgets/news_detail/news_detail_more_button.dart';
import '../widgets/news_detail/related_articles_widget.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = ModalRoute.of(context)!.settings.arguments as Article;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewsDetailHeader(imageUrl: article.thumb),
            NewsDetailContent(
              title: article.category?.name ?? '',
              date: article.publishDate,
              content: article.content,
            ),
            NewsDetailMoreButton(article: article),
            const SizedBox(height: 20),
            RelatedArticlesWidget(
              categoryId: article.categoryId,
              currentArticleId: article.id,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
