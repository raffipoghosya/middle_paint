import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/controllers/drawing_controller.dart';
import 'dart:io';

class DrawingPainter extends CustomPainter {
  final DrawingController controller;
  DrawingPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var path in controller.paths) {
      for (int i = 0; i < path.length - 1; i++) {
        final current = path[i];
        final next = path[i + 1];

        canvas.drawLine(current.point, next.point, current.paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}

class DrawingArea extends StatelessWidget {
  static const double horizontalPadding = 21.0;
  static const double bottomClearance = 80.0;

  final double appBarHeight;
  final DrawingController controller;
  final String? backgroundImagePath;
  final Size? imageNaturalSize;
  final GlobalKey repaintBoundaryKey;
  final ValueChanged<Rect?>? onBoundsCalculated;

  const DrawingArea({
    super.key,
    required this.appBarHeight,
    required this.controller,
    this.backgroundImagePath,
    this.imageNaturalSize,
    required this.repaintBoundaryKey,
    this.onBoundsCalculated,
  });

  bool _isPointInBounds(Offset point, Rect bounds) {
    return point.dx >= bounds.left &&
        point.dx <= bounds.right &&
        point.dy >= bounds.top &&
        point.dy <= bounds.bottom;
  }

  Rect _calculateContainedImageBounds(Size canvasSize, Size? naturalSize) {
    if (naturalSize == null ||
        naturalSize.width <= 0 ||
        naturalSize.height <= 0) {
      return Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }

    final canvasRatio = canvasSize.width / canvasSize.height;
    final imageRatio = naturalSize.width / naturalSize.height;

    double actualWidth;
    double actualHeight;
    double offsetX;
    double offsetY;

    if (imageRatio > canvasRatio) {
      actualWidth = canvasSize.width;
      actualHeight = actualWidth / imageRatio;
      offsetX = 0;
      offsetY = (canvasSize.height - actualHeight) / 2;
    } else {
      actualHeight = canvasSize.height;
      actualWidth = actualHeight * imageRatio;
      offsetY = 0;
      offsetX = (canvasSize.width - actualWidth) / 2;
    }

    return Rect.fromLTWH(offsetX, offsetY, actualWidth, actualHeight);
  }

  @override
  Widget build(BuildContext context) {
    final double topSpaceForToolIcons = 24.h * 2 + 22.w;
    final double topPaddingInsideRepaintBoundary = topSpaceForToolIcons + 10.h;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      top: appBarHeight,
      left: horizontalPadding.w,
      right: horizontalPadding.w,
      bottom: bottomClearance.h + bottomPadding,

      child: RepaintBoundary(
        key: repaintBoundaryKey,
        child: Padding(
          padding: EdgeInsets.only(top: topPaddingInsideRepaintBoundary),
          child: Container(
            decoration: BoxDecoration(
              color:
                  backgroundImagePath != null
                      ? Colors.transparent
                      : Colors.white,

              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlack.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = constraints.biggest;

                Rect drawingBounds =
                    backgroundImagePath != null
                        ? _calculateContainedImageBounds(
                          canvasSize,
                          imageNaturalSize,
                        )
                        : Rect.fromLTWH(
                          0,
                          0,
                          canvasSize.width,
                          canvasSize.height,
                        );

                final Rect absoluteDrawingBounds = Rect.fromLTWH(
                  drawingBounds.left,
                  drawingBounds.top + topPaddingInsideRepaintBoundary,
                  drawingBounds.width,
                  drawingBounds.height,
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onBoundsCalculated?.call(absoluteDrawingBounds);
                });

                return Stack(
                  children: [
                    if (backgroundImagePath != null)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(backgroundImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                    GestureDetector(
                      onPanStart: (details) {
                        final localPosition = details.localPosition;
                        if (_isPointInBounds(localPosition, drawingBounds)) {
                          controller.startNewPath(localPosition);
                        }
                      },
                      onPanUpdate: (details) {
                        final localPosition = details.localPosition;

                        if (controller.paths.isNotEmpty &&
                            _isPointInBounds(localPosition, drawingBounds)) {
                          controller.addPointToCurrentPath(localPosition);
                        }
                      },
                      onPanEnd: (_) {
                        controller.endPath();
                      },
                      child: ClipRect(
                        clipper: _ImageClipper(drawingBounds),
                        child: ListenableBuilder(
                          listenable: controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: DrawingPainter(controller),
                              child: Container(color: Colors.transparent),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final Rect clipRect;

  _ImageClipper(this.clipRect);

  @override
  Rect getClip(Size size) {
    return clipRect;
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return oldClipper.clipRect != clipRect;
  }
}
