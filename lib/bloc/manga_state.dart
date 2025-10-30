part of 'manga_cubit.dart';

abstract class MangaState extends Equatable {
  const MangaState();

  @override
  List<Object> get props => [];
}

class MangaInitial extends MangaState {}

class MangaLoading extends MangaState {}

class MangaLoaded extends MangaState {
  final List<Manga> mangaList;
  final int totalResults;

  const MangaLoaded(this.mangaList, this.totalResults);

  @override
  List<Object> get props => [mangaList, totalResults];
}

class MangaError extends MangaState {
  final String message;

  const MangaError(this.message);

  @override
  List<Object> get props => [message];
}
