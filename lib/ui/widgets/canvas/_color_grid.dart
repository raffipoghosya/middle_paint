import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColorGrid extends StatelessWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final Map<String, List<Color>> palettes;

  const ColorGrid({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.palettes,
  });

  static const List<String> verticalOrder = [
    'blueCyanPalette',
    'deepBluePalette',
    'purplePalette',
    'magentaPurplePalette',
    'rosePalette',
    'redPalette',
    'orangePalette',
    'goldenPalette',
    'yellowPalette',
    'limeYellowPalette',
    'oliveGreenPalette',
    'forestGreenPalette',
  ];

  @override
  Widget build(BuildContext context) {
    final grayscale = palettes['grayscalePalette'] ?? [];
    final int columnCount = grayscale.length;
    final int maxRowCount =
        grayscale.isEmpty
            ? 0
            : 1 + (palettes[verticalOrder.first]?.length ?? 0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(columnCount, (index) {
          final Color grayColor = grayscale[index];
          final String? paletteKey =
              index < verticalOrder.length ? verticalOrder[index] : null;
          final List<Color> verticalColors =
              paletteKey != null ? (palettes[paletteKey] ?? []) : [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorBox(
                color: grayColor,
                colIndex: index,
                rowIndex: 0,
                colCount: columnCount,
                rowCount: maxRowCount,
                onColorChanged: onColorChanged,
                initialColor: initialColor,
              ),
              ...verticalColors.asMap().entries.map((entry) {
                final rowIdx = entry.key + 1;
                final Color c = entry.value;
                return _buildColorBox(
                  color: c,
                  colIndex: index,
                  rowIndex: rowIdx,
                  colCount: columnCount,
                  rowCount: maxRowCount,
                  onColorChanged: onColorChanged,
                  initialColor: initialColor,
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildColorBox({
    required Color color,
    required int colIndex,
    required int rowIndex,
    required int colCount,
    required int rowCount,
    required ValueChanged<Color> onColorChanged,
    required Color initialColor,
  }) {
    final bool isSelected = color == initialColor;
    final bool isTopRow = rowIndex == 0;
    final bool isBottomRow = rowIndex == rowCount - 1;
    final bool isLeftCol = colIndex == 0;
    final bool isRightCol = colIndex == colCount - 1;

    BorderRadius borderRadius = BorderRadius.zero;
    final double innerCornerRadius = 16.r;

    if (isTopRow && isLeftCol) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(innerCornerRadius),
      );
    } else if (isTopRow && isRightCol) {
      borderRadius = BorderRadius.only(
        topRight: Radius.circular(innerCornerRadius),
      );
    } else if (isBottomRow && isLeftCol) {
      borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(innerCornerRadius),
      );
    } else if (isBottomRow && isRightCol) {
      borderRadius = BorderRadius.only(
        bottomRight: Radius.circular(innerCornerRadius),
      );
    }

    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        margin: EdgeInsets.zero,
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: color,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
