import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/genre_model.dart';
import '../services/api_service.dart';

part 'genre_state.dart';

class GenreCubit extends Cubit<GenreState> {
  final ApiService _apiService;

  GenreCubit(this._apiService) : super(GenreInitial());

  Future<void> fetchGenres() async {
    emit(GenreLoading());
    try {
      final genres = await _apiService.fetchGenres();
      emit(GenreLoaded(genres));
    } catch (e) {
      emit(GenreError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
