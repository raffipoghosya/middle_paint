import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/constants/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;

  final List<Widget>? actions;

  final String? title;

  const CustomAppBar({super.key, this.leading, this.actions, this.title});

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppConstants.contentHeight + 44.0);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double appBarHeight = AppConstants.contentHeight + topPadding;

    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        color: AppColors.shadowPurple,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowPurple,
                offset: const Offset(0, -82),
                blurRadius: 68.r,
                spreadRadius: -64.r,
              ),
              BoxShadow(
                color: AppColors.shadowGray.withValues(alpha: 0.05),
                offset: const Offset(0, 1),
                blurRadius: 40.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Column(
              children: [
                SizedBox(height: topPadding),
                SizedBox(
                  height: AppConstants.contentHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        leading ?? SizedBox(width: 24.w),

                        Expanded(
                          child: Center(
                            child: Text(
                              title ?? 'Галерея',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.neutral50,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions ?? [SizedBox(width: 24.w)],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
