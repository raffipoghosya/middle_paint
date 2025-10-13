import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class MainButton extends StatelessWidget {
  MainButton({
    required this.buttonText,
    required this.textColor,
    this.buttonColors,
    required this.onTap,
    super.key,
  }) : assert(
         buttonColors == null || buttonColors.isNotEmpty,
         'buttonColors must not be empty if provided.',
       );

  final String buttonText;
  final List<Color>? buttonColors;
  final Color textColor;
  final VoidCallback onTap;

  static const Color _defaultSolidColor = AppColors.neutral50;

  Decoration _getDecoration() {
    if (buttonColors == null || buttonColors!.isEmpty) {
      return BoxDecoration(
        color: _defaultSolidColor,
        borderRadius: BorderRadius.circular(8),
      );
    } else if (buttonColors!.length == 1) {
      return BoxDecoration(
        color: buttonColors![0],
        borderRadius: BorderRadius.circular(8),
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: buttonColors!,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _getDecoration(),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        width: double.infinity,
        child: Center(
          child: Text(
            buttonText,
            style: textTheme.titleMedium!.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
