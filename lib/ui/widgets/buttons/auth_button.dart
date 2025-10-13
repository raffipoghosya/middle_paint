import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class AuthButton extends StatefulWidget {
  const AuthButton({
    super.key,
    required this.buttonName,
    this.onTap,
    this.disabled = false,
    this.loading = false,
  });
  final String buttonName;
  final VoidCallback? onTap;
  final bool disabled;
  final bool loading;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  void _onTapDown(_) {
    if (!widget.loading && !widget.disabled) {}
  }

  void _onTapUp(_) {
    if (!widget.loading && !widget.disabled) {}
  }

  void _onTapCancel() {}

  BoxDecoration _getBoxDecoration() {
    if (widget.loading) {
      return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
        gradient: LinearGradient(
          colors: [AppColors.magenta, AppColors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }

    if (widget.disabled) {
      return BoxDecoration(
        color: AppColors.borderGray,
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      );
    }

    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8.r)),
      gradient: LinearGradient(
        colors: [AppColors.magenta, AppColors.purple],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Color _getTextColor() {
    if (widget.loading || !widget.disabled) {
      return AppColors.primary50;
    }

    return AppColors.grayDark;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isActive = !widget.loading && !widget.disabled;

    return SizedBox(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isActive ? widget.onTap : null,

        child: Opacity(
          opacity: widget.loading ? 0.7 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: _getBoxDecoration(),
            alignment: Alignment.center,

            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading)
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        color: AppColors.primary50,
                        strokeWidth: 2,
                      ),
                    ),

                  SizedBox(width: widget.loading ? 8 : 20),
                  Text(
                    widget.buttonName,
                    style: textTheme.titleMedium!.copyWith(
                      color: _getTextColor(),
                    ),
                  ),

                  SizedBox(width: 20.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
