class News {
  final String id;
  final String imageUrl;
  final String category;
  final String title;
  final String date;
  final String content;
  bool isFavorite;

  News({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
    required this.content,
    this.isFavorite = false,
  });
}
