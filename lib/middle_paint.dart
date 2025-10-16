import 'package:flutter/material.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/text_theme/text_theme.dart';
import 'package:middle_paint/core/routes/routes.dart';

class MiddlePaint extends StatelessWidget {
  const MiddlePaint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Middle Paint',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: AppColors.neutral400,
          selectionHandleColor: AppColors.neutral400,
          cursorColor: AppColors.neutral400,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          primary: AppColors.primary100,
          secondary: AppColors.appbarGray,
        ),
        primaryTextTheme: AppTextTheme.primaryTextTheme,
        textTheme: AppTextTheme.secondaryTextTheme,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
