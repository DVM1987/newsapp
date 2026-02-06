import 'package:flutter/material.dart';

import '../models/news.dart';
import '../widgets/news_detail/news_detail_content.dart';
import '../widgets/news_detail/news_detail_header.dart';
import '../widgets/news_detail/news_detail_more_button.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = ModalRoute.of(context)!.settings.arguments as News;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewsDetailHeader(imageUrl: news.imageUrl),
            NewsDetailContent(
              title: news
                  .category, // In the UI, 'Political' (category) is the main title
              date: news.date,
              content: news.content,
            ),
            const NewsDetailMoreButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
