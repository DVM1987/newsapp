import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/article.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';

class NewsDetailHeader extends StatelessWidget {
  final Article article;

  const NewsDetailHeader({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        article.thumb.isEmpty
            ? Container(
                width: double.infinity,
                height: 350,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              )
            : CachedNetworkImage(
                imageUrl: article.thumb,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 50),
                ),
              ),
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: Consumer<NewsProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.isFavorite(article.id);
              return GestureDetector(
                onTap: () {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (!authProvider.isLoggedIn) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng đăng nhập để sử dụng tính năng này',
                        ),
                      ),
                    );
                    return;
                  }
                  provider.toggleFavoriteStatus(article.id, article: article);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Đã xóa khỏi danh sách yêu thích'
                            : 'Đã thêm vào danh sách yêu thích',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
