import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class ToolIcon extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;
  final Color? color;
  final bool isEnabled;
  final double leftPadding;
  final bool isSmall;

  const ToolIcon({
    super.key,
    required this.assetName,
    required this.onTap,
    this.color,
    this.isEnabled = true,
    this.leftPadding = 12.0,
    this.isSmall = false,
  });

  double get _iconSize => isSmall ? 18.w : 22.w;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = color ?? AppColors.neutral20;

    final Color effectiveBackgroundColor =
        isEnabled
            ? backgroundColor
            : AppColors.neutral20.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding.w),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              assetName,
              width: _iconSize,
              height: _iconSize,
              colorFilter: ColorFilter.mode(
                AppColors.primary50,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
