// lib/article.dart
class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      urlToImage: (json['urlToImage'] != null &&
          json['urlToImage'].toString().isNotEmpty)
          ? json['urlToImage'].toString()
          : 'https://via.placeholder.com/150',
      url: json['url']?.toString() ?? '',
    );
  }
}