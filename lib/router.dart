import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'models/manga_model.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'manga/:id',
          builder: (BuildContext context, GoRouterState state) {
            final Manga manga = state.extra as Manga;
            return DetailScreen(manga: manga);
          },
        ),
      ],
    ),
  ],
);
