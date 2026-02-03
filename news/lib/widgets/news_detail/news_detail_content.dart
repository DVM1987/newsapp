import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

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
          Text(
            content,
            style: const TextStyle(
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
