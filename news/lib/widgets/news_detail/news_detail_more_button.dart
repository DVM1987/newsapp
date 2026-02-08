import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../apps/constants/app_colors.dart';
import '../../models/article.dart';

class NewsDetailMoreButton extends StatelessWidget {
  final Article article;

  const NewsDetailMoreButton({super.key, required this.article});

  Future<void> _launchUrl() async {
    final url = article.link;
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
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
          onPressed: _launchUrl,
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
