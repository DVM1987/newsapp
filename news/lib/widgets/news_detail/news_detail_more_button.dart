import 'package:flutter/material.dart';

import '../../apps/constants/app_colors.dart';
import '../../apps/routers/router_name.dart';
import '../../models/article.dart';

class NewsDetailMoreButton extends StatelessWidget {
  final Article article;

  const NewsDetailMoreButton({super.key, required this.article});

  void _launchUrl(BuildContext context) {
    if (article.link == null || article.link!.isEmpty) return;

    Navigator.of(context).pushNamed(
      RouterName.webView,
      arguments: {'url': article.link, 'title': article.title},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (article.link == null || article.link!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: 150,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _launchUrl(context),
          child: const Text(
            'More',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
