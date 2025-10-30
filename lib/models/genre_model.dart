class Genre {
  final String id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    String name = 'Unknown';
    if (json['attributes']?['name'] is Map) {
      name = json['attributes']['name']['en'] ?? 'Unknown';
    }
    return Genre(
      id: json['id'] as String,
      name: name,
    );
  }
}
