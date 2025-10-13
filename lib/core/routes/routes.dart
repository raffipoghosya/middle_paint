import 'package:flutter/material.dart';
import 'package:middle_paint/ui/authentication/sign_in.dart';
import 'package:middle_paint/ui/authentication/sign_up.dart';
import 'package:middle_paint/ui/splash/splash_screen.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';
import 'package:middle_paint/ui/canvas/canvas_screen.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

class AppRoutes {
  static Route<dynamic> slideTransitionRoute(
    Widget page,
    RouteSettings settings, {
    bool reverse = false,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin =
            reverse ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.name:
        return slideTransitionRoute(const SplashScreen(), settings);

      case SignInScreen.name:
        return slideTransitionRoute(const SignInScreen(), settings);

      case SignUpScreen.name:
        return slideTransitionRoute(const SignUpScreen(), settings);

      case HomeScreen.name:
        return slideTransitionRoute(const HomeScreen(), settings);

      case CanvasScreen.name:
        final arguments = settings.arguments;
        ArtworkModel? artworkToEdit;

        if (arguments is ArtworkModel) {
          artworkToEdit = arguments;
        }

        return slideTransitionRoute(
          CanvasScreen(artworkToEdit: artworkToEdit),
          settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
