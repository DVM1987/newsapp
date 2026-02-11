import 'category.dart';

class Article {
  final int id;
  final String title;
  final String description;
  final String slug;
  final String content;
  final String thumb;
  final String? link;
  final String author;
  final int? views;
  final String publishDate;
  final int status;
  final int categoryId;
  final Category? category;
  bool isFavorite;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.content,
    required this.thumb,
    this.link,
    required this.author,
    this.views,
    required this.publishDate,
    required this.status,
    required this.categoryId,
    this.category,
    this.isFavorite = false,
  });

  Article copyWith({
    int? id,
    String? title,
    String? description,
    String? slug,
    String? content,
    String? thumb,
    String? link,
    String? author,
    int? views,
    String? publishDate,
    int? status,
    int? categoryId,
    Category? category,
    bool? isFavorite,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      content: content ?? this.content,
      thumb: thumb ?? this.thumb,
      link: link ?? this.link,
      author: author ?? this.author,
      views: views ?? this.views,
      publishDate: publishDate ?? this.publishDate,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      thumb: json['thumb'] ?? '',
      link: json['link'],
      author: json['author'] ?? '',
      views: json['views'],
      publishDate: json['publish_date'] ?? '',
      status: json['status'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'slug': slug,
      'content': content,
      'thumb': thumb,
      'link': link,
      'author': author,
      'views': views,
      'publish_date': publishDate,
      'status': status,
      'category_id': categoryId,
      'category': category?.toJson(),
      'isFavorite': isFavorite,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
