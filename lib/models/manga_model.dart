class Manga {
  final String id;
  final String title;
  final String description;
  final String coverUrl;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    String mangaId = json['id'] ?? '';
    
    String title = 'No Title';
    if (json['attributes']?['title'] is Map) {
      title = json['attributes']['title']['en'] 
              ?? json['attributes']['title'].values.first 
              ?? 'No Title';
    }

    String description = 'No description available.';
    if (json['attributes']?['description'] is Map) {
      description = json['attributes']['description']['en'] ?? description;
    }

    String coverFileName = '';
    var coverArtRelationship = (json['relationships'] as List?)
        ?.firstWhere((rel) => rel['type'] == 'cover_art', orElse: () => null);

    if (coverArtRelationship != null && coverArtRelationship['attributes'] != null) {
      coverFileName = coverArtRelationship['attributes']['fileName'] ?? '';
    }

    String coverUrl = '';
    if (mangaId.isNotEmpty && coverFileName.isNotEmpty) {
      coverUrl = 'https://uploads.mangadex.org/covers/$mangaId/$coverFileName';
    }

    return Manga(
      id: mangaId,
      title: title,
      description: description,
      coverUrl: coverUrl,
    );
  }
}
