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
          path: 'manga/:title', // Changed from :id to :title
          builder: (BuildContext context, GoRouterState state) {
            // The manga object is passed as an extra parameter.
            // The title in the URL is for user-friendly deep linking.
            final Manga manga = state.extra as Manga;
            return DetailScreen(manga: manga);
          },
        ),
      ],
    ),
  ],
);
