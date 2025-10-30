import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'bloc/genre_cubit.dart';
import 'bloc/manga_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<GenreCubit>(
          create: (context) => GenreCubit(apiService)..fetchGenres(),
        ),
        BlocProvider<MangaCubit>(
          create: (context) => MangaCubit(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Manga Reader',
        theme: ThemeData(
          primaryColor: const Color(0xFF5D4037),
          primaryColorDark: const Color(0xFF4E342E),
          primaryColorLight: const Color(0xFF8D6E63),
          scaffoldBackgroundColor: const Color(0xFFF1F8E9),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5D4037),
            secondary: Color(0xFF8BC34A),
            onPrimary: Colors.white,
            error: Colors.redAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF33691E),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            shadowColor: Colors.grey.withAlpha(51),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
