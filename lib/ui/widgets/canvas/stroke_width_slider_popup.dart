import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:middle_paint/ui/widgets/canvas/drawing_area.dart';

class StrokeWidthSliderPopup extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onTapOutside;

  const StrokeWidthSliderPopup({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.onTapOutside,
  });

  @override
  State<StrokeWidthSliderPopup> createState() => _StrokeWidthSliderPopupState();
}

class _StrokeWidthSliderPopupState extends State<StrokeWidthSliderPopup> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = AppConstants.contentHeight + topPadding;

    final double iconRowTotalHeight = 24.h + 40.h + 24.h;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double canvasWidth =
        screenWidth - (DrawingArea.horizontalPadding * 2).w;

    return GestureDetector(
      onTap: widget.onTapOutside,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.topCenter,

        child: Padding(
          padding: EdgeInsets.only(
            top: appBarHeight + iconRowTotalHeight + 8.h,
            left: DrawingArea.horizontalPadding.w,
            right: DrawingArea.horizontalPadding.w,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: canvasWidth,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderGray, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20.0,
                        ),
                        trackHeight: 4.h,
                        activeTrackColor: AppColors.magenta,
                        inactiveTrackColor: AppColors.borderGray.withValues(
                          alpha: 0.5,
                        ),
                        thumbColor: AppColors.purple,
                        overlayColor: AppColors.purple.withValues(alpha: 0.2),
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        showValueIndicator: ShowValueIndicator.never,
                      ),
                      child: Slider(
                        value: _currentSliderValue,
                        min: 1.0,
                        max: 50.0,
                        onChanged: (double newValue) {
                          setState(() {
                            _currentSliderValue = newValue;
                          });
                          widget.onChanged(newValue);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
