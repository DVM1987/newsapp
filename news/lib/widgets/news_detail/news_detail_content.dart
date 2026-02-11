import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../apps/constants/app_colors.dart';
import '../../apps/routers/router_name.dart';

class NewsDetailContent extends StatelessWidget {
  final String title;
  final String date;
  final String content;

  const NewsDetailContent({
    super.key,
    required this.title,
    required this.date,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
          const SizedBox(height: 16),
          HtmlWidget(
            content,
            onTapUrl: (url) {
              Navigator.of(context).pushNamed(
                RouterName.webView,
                arguments: {'url': url, 'title': title},
              );
              return true;
            },
            textStyle: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
