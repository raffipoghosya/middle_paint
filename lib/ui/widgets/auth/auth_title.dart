import 'package:flutter/material.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class AuthTitle extends StatelessWidget {
  const AuthTitle(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).primaryTextTheme;

    return Text(
      title,
      style: textTheme.headlineSmall?.copyWith(
        color: AppColors.neutral50,
        shadows: [
          Shadow(
            offset: Offset(-2, -3),
            blurRadius: 20.0,
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}
