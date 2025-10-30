class Article {
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String sourceName;

  Article({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
      sourceName: (json['source'] as Map<String, dynamic>)['name'] as String,
    );
  }
}
