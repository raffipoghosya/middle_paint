import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_paint/base/text_theme/text_styles.dart';

class AppTextTheme {
  static final primaryTextTheme = GoogleFonts.pressStart2pTextTheme(
    TextTheme(
      headlineLarge: TextStyles.headlineBold,
      headlineMedium: TextStyles.headlineMedium,
      headlineSmall: TextStyles.headlineRegular,
    ),
  );

  static final secondaryTextTheme = GoogleFonts.robotoTextTheme(
    TextTheme(
      titleLarge: TextStyles.bodyBold,
      titleMedium: TextStyles.bodyMedium,
      titleSmall: TextStyles.bodyRegular,
      bodyLarge: TextStyles.captionBold,
      bodyMedium: TextStyles.captionMedium,
      bodySmall: TextStyles.captionRegular,
      labelLarge: TextStyles.footnoteBold,
      labelMedium: TextStyles.footnoteMedium,
      labelSmall: TextStyles.footnoteRegular,
    ),
  );
}
