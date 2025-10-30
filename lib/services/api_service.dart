import 'package:dio/dio.dart';
import '../models/manga_model.dart';
import '../models/genre_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.mangadex.org';

  Future<List<Genre>> fetchGenres() async {
    try {
      final response = await _dio.get('$_baseUrl/manga/tag');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .where((tag) => tag['attributes']['group'] == 'genre')
            .map((json) => Genre.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load genres');
      }
    } on DioException catch (e) {
      throw Exception('Failed to connect: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> fetchManga({
    String query = '',
    int limit = 20,
    int offset = 0,
    List<String> includedGenreIDs = const [],
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/manga',
        queryParameters: {
          'title': query.isNotEmpty ? query : null,
          'limit': limit,
          'offset': offset,
          'includedTags[]': includedGenreIDs.isNotEmpty ? includedGenreIDs : null,
          'includes[]': 'cover_art',
          'order[latestUploadedChapter]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final int total = response.data['total'] ?? 0;
        final List<Manga> mangaList = data.map((json) => Manga.fromJson(json)).toList();
        
        return {
          'mangaList': mangaList,
          'total': total,
        };
      } else {
        throw Exception('Failed to load manga');
      }
    } on DioException catch (e) {
      throw Exception('Failed to connect: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
