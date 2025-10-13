import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:middle_paint/gen/assets.gen.dart';
import 'package:middle_paint/ui/widgets/canvas/_color_grid.dart';
import 'package:middle_paint/ui/widgets/canvas/_rounded_pointer_painter.dart';

class ColorPickerPopup extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onTapOutside;

  const ColorPickerPopup({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.onTapOutside,
  });

  @override
  State<ColorPickerPopup> createState() => _ColorPickerPopupState();
}

class _ColorPickerPopupState extends State<ColorPickerPopup> {
  Map<String, List<Color>>? _palettes;

  @override
  void initState() {
    super.initState();
    _loadColorData();
  }

  @override
  void didUpdateWidget(covariant ColorPickerPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor != widget.initialColor) {
      setState(() {});
    }
  }

  Future<void> _loadColorData() async {
    try {
      final jsonString = await rootBundle.loadString(Assets.json.colorPalette);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final Map<String, List<Color>> loadedPalettes = {};

      for (final entry in jsonMap.entries) {
        final List<String> hexCodes = List<String>.from(entry.value);
        loadedPalettes[entry.key] =
            hexCodes
                .map(
                  (hex) =>
                      Color(int.parse(hex.replaceFirst('0x', ''), radix: 16)),
                )
                .toList();
      }

      setState(() {
        _palettes = loadedPalettes;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = AppConstants.contentHeight + topPadding;

    final double iconRowVerticalPadding = 24.h;
    final double iconDiameter = 40.h;
    final double marginBelowIconRow = 4.h;

    final double popupTopPosition =
        appBarHeight +
        iconRowVerticalPadding +
        iconDiameter +
        marginBelowIconRow;

    final double popupRightPadding = 16.w;
    final double pointerRightOffset = 20.w;

    return GestureDetector(
      onTap: widget.onTapOutside,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(
            top: popupTopPosition,
            right: popupRightPadding,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -14,
                right: pointerRightOffset,
                child: CustomPaint(
                  size: Size(32.w, 20.h),
                  painter: RoundedPointerPainter(),
                ),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgGray,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    child:
                        _palettes == null
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6A46F9),
                              ),
                            )
                            : ColorGrid(
                              palettes: _palettes!,
                              initialColor: widget.initialColor,
                              onColorChanged: (color) {
                                widget.onColorChanged(color);
                              },
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
