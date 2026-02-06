class Category {
  final int id;
  final String name;
  final String slug;
  final String link;
  final int articlesCount;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.link,
    required this.articlesCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      link: json['link'] ?? '',
      articlesCount: json['articles_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'link': link,
      'articles_count': articlesCount,
    };
  }
}
