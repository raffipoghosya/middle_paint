import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:middle_paint/ui/authentication/sign_in.dart';
import 'package:middle_paint/ui/authentication/sign_up.dart';
import 'package:middle_paint/ui/splash/splash_screen.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';
import 'package:middle_paint/ui/canvas/canvas_screen.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: SplashScreen.name,
    routes: <RouteBase>[
      GoRoute(
        path: SplashScreen.name,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: SignInScreen.name,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
        ),
      ),
      GoRoute(
        path: SignUpScreen.name,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          durationMs: 500,
        ),
      ),
      GoRoute(
        path: HomeScreen.name,
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: CanvasScreen.name,
        pageBuilder: (context, state) {
          final Object? extra = state.extra;
          ArtworkModel? artworkToEdit;
          if (extra is ArtworkModel) {
            artworkToEdit = extra;
          }
          return _slideTransitionPage(
            key: state.pageKey,
            child: CanvasScreen(artworkToEdit: artworkToEdit),
          );
        },
      ),
    ],
  );

  static CustomTransitionPage _slideTransitionPage({
    required LocalKey key,
    required Widget child,
    int durationMs = 250,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: Duration(milliseconds: durationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}