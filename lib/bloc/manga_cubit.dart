import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/manga_model.dart';
import '../services/api_service.dart';

part 'manga_state.dart';

class MangaCubit extends Cubit<MangaState> {
  final ApiService _apiService;

  MangaCubit(this._apiService) : super(MangaInitial());

  Future<void> fetchManga({
    String query = '',
    int page = 1,
    int limit = 20,
    List<String> includedGenreIDs = const [],
  }) async {
    emit(MangaLoading());
    try {
      final int offset = (page - 1) * limit;
      final result = await _apiService.fetchManga(
        query: query,
        limit: limit,
        offset: offset,
        includedGenreIDs: includedGenreIDs,
      );
      final mangaList = result['mangaList'] as List<Manga>;
      final total = result['total'] as int;
      emit(MangaLoaded(mangaList, total));
    } catch (e) {
      emit(MangaError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void clear() {
    emit(MangaInitial());
  }
}
