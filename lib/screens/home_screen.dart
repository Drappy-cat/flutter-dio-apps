import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/manga_model.dart';
import '../models/genre_model.dart';
import 'detail_screen.dart';
import 'dart:math';
import '../bloc/genre_cubit.dart';
import '../bloc/manga_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _selectedGenreIDs = [];
  String _currentSearchQuery = '';
  int _currentPage = 1; // Keep track of current page locally for pagination UI

  @override
  void initState() {
    super.initState();
    // Listen for genre loading to trigger initial manga fetch
    // If genres are already loaded (e.g., hot restart), fetch manga immediately
    final genreState = context.read<GenreCubit>().state;
    if (genreState is GenreLoaded) {
      _fetchManga();
    } else if (genreState is GenreInitial) {
      // If initial, wait for genres to load via listener
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchManga({int page = 1}) {
    _currentPage = page;
    context.read<MangaCubit>().fetchManga(
          query: _currentSearchQuery,
          page: _currentPage,
          includedGenreIDs: _selectedGenreIDs,
        );
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _currentSearchQuery = value;
        _selectedGenreIDs.clear(); // Clear genres when searching
      });
      _fetchManga(page: 1);
    }
  }

  void _showGenreFilter(BuildContext context) {
    final tempSelectedGenreIDs = List<String>.from(_selectedGenreIDs);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filter Berdasarkan Genre', style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedGenreIDs.clear();
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: BlocBuilder<GenreCubit, GenreState>(
                      builder: (context, genreState) {
                        if (genreState is GenreLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (genreState is GenreError) {
                          return Center(child: Text('Gagal memuat genre: ${genreState.message}'));
                        } else if (genreState is GenreLoaded) {
                          final allGenres = genreState.genres;
                          return ListView(
                            children: allGenres.map((genre) {
                              return CheckboxListTile(
                                title: Text(genre.name),
                                value: tempSelectedGenreIDs.contains(genre.id),
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      tempSelectedGenreIDs.add(genre.id);
                                    } else {
                                      tempSelectedGenreIDs.remove(genre.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink(); // Should not happen
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGenreIDs.clear();
                                _selectedGenreIDs.addAll(tempSelectedGenreIDs);
                                _currentSearchQuery = ''; // Clear search query when applying genre filter
                                _searchController.clear();
                              });
                              Navigator.pop(context);
                              _fetchManga(page: 1);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Terapkan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearchQuery = '';
      _selectedGenreIDs.clear();
    });
    context.read<MangaCubit>().clear(); // Reset MangaCubit to initial state
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenreCubit, GenreState>(
      listener: (context, genreState) {
        if (genreState is GenreLoaded && context.read<MangaCubit>().state is MangaInitial) {
          _fetchManga(); // Initial fetch after genres are loaded
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              _buildSearchAndFilter(),
              Expanded(
                child: BlocBuilder<MangaCubit, MangaState>(
                  builder: (context, mangaState) {
                    return _buildContentArea(mangaState);
                  },
                ),
              ),
              BlocBuilder<MangaCubit, MangaState>(
                builder: (context, mangaState) {
                  if (mangaState is MangaLoaded && mangaState.mangaList.isNotEmpty) {
                    return _buildSmartPaginationControls(mangaState.totalResults, mangaState.mangaList.length);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: const Text(
        'Manga Reader',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari manga...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
                    filled: true,
                    fillColor: Colors.white.withAlpha(230),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                  ),
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
              const SizedBox(width: 8),
              _buildGenreDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: IconButton(
        icon: Icon(Icons.filter_list, color: Theme.of(context).primaryColorDark),
        tooltip: "Filter Genre",
        onPressed: () => _showGenreFilter(context),
      ),
    );
  }

  Widget _buildContentArea(MangaState mangaState) {
    if (mangaState is MangaLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (mangaState is MangaError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Gagal memuat manga.\n${mangaState.message}', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16)),
        ),
      );
    }
    if (mangaState is MangaInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Pilih genre atau cari manga untuk memulai', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    if (mangaState is MangaLoaded) {
      if (mangaState.mangaList.isEmpty) {
        return const Center(child: Text('Tidak ada manga yang ditemukan dengan filter ini.'));
      }
      return _buildMangaGrid(mangaState.mangaList);
    }
    return const SizedBox.shrink(); // Fallback
  }

  Widget _buildMangaGrid(List<Manga> mangaList) {
    return MasonryGridView.count(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      crossAxisCount: 2,
      itemCount: mangaList.length,
      itemBuilder: (BuildContext context, int index) => _buildMangaCard(mangaList[index]),
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
    );
  }

  Widget _buildSmartPaginationControls(int totalResults, int currentMangaCount) {
    final int totalPages = (totalResults / 20).ceil(); // Assuming _limit is 20
    if (totalPages <= 1) return const SizedBox.shrink();

    List<Widget> pageWidgets = [];
    const int maxVisiblePages = 5;

    pageWidgets.add(
      IconButton(onPressed: _currentPage > 1 ? () => _fetchManga(page: _currentPage - 1) : null, icon: const Icon(Icons.arrow_back_ios), tooltip: 'Sebelumnya'),
    );

    if (totalPages <= maxVisiblePages) {
      for (int i = 1; i <= totalPages; i++) {
        pageWidgets.add(_buildPageNumberButton(i));
      }
    } else {
      pageWidgets.add(_buildPageNumberButton(1));
      if (_currentPage > 3) {
        pageWidgets.add(_buildEllipsis());
      }
      int start = max(2, _currentPage - 1);
      int end = min(totalPages - 1, _currentPage + 1);
      for (int i = start; i <= end; i++) {
        pageWidgets.add(_buildPageNumberButton(i));
      }
      if (_currentPage < totalPages - 2) {
        pageWidgets.add(_buildEllipsis());
      }
      pageWidgets.add(_buildPageNumberButton(totalPages));
    }

    pageWidgets.add(
      IconButton(onPressed: _currentPage < totalPages ? () => _fetchManga(page: _currentPage + 1) : null, icon: const Icon(Icons.arrow_forward_ios), tooltip: 'Berikutnya'),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: pageWidgets),
    );
  }

  Widget _buildPageNumberButton(int page) {
    bool isCurrent = page == _currentPage;
    return InkWell(
      onTap: () => _fetchManga(page: page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent ? Theme.of(context).primaryColor : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isCurrent ? Colors.transparent : Colors.grey.shade400),
        ),
        child: Text('$page', style: TextStyle(color: isCurrent ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMangaCard(Manga manga) {
    final genreState = context.watch<GenreCubit>().state;
    List<String> genreNames = [];
    if (genreState is GenreLoaded) {
      genreNames = manga.genreIds
          .map((id) => genreState.genres.firstWhere((genre) => genre.id == id, orElse: () => Genre(id: '', name: 'Unknown')).name)
          .take(3) // Limit to 3 genres for cleaner look
          .toList();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(manga: manga))),
        child: Stack(
          children: [
            _buildCoverImage(manga.coverUrl),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black87)]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (genreNames.isNotEmpty)
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 2.0,
                        children: genreNames.map((name) => Chip(
                          label: Text(name, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          backgroundColor: Colors.black.withOpacity(0.3),
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String coverUrl) {
    return AspectRatio(
      aspectRatio: 2 / 3, // Common manga cover aspect ratio
      child: coverUrl.isNotEmpty
          ? Image.network(coverUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder())
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
    );
  }
}
