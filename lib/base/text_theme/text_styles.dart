import 'package:flutter/material.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  //headline

  static TextStyle headlineRegular = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary100,
    height: AppConstants.headlineTextHeight,
  );
  static TextStyle headlineMedium = headlineRegular.copyWith(
    fontWeight: FontWeight.w500,
  );
  static TextStyle headlineBold = headlineRegular.copyWith(
    fontWeight: FontWeight.w700,
  );

  // body

  static TextStyle bodyRegular = TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary100,
    height: AppConstants.bodyTextHeight,
  );
  static TextStyle bodyMedium = bodyRegular.copyWith(
    fontWeight: FontWeight.w500,
  );
  static TextStyle bodyBold = bodyRegular.copyWith(fontWeight: FontWeight.w700);

  // caption

  static TextStyle captionRegular = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary100,
    height: AppConstants.captionTextHeight,
  );
  static TextStyle captionMedium = captionRegular.copyWith(
    fontWeight: FontWeight.w500,
  );
  static TextStyle captionBold = captionRegular.copyWith(
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  // footnote

  static TextStyle footnoteRegular = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary100,
    height: AppConstants.footnoteTextHeight,
  );
  static TextStyle footnoteMedium = footnoteRegular.copyWith(
    fontWeight: FontWeight.w500,
  );
  static TextStyle footnoteBold = footnoteRegular.copyWith(
    fontWeight: FontWeight.w700,
  );
}
