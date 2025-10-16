import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/controllers/drawing_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_bloc.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_state.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_event.dart';
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

                return BlocBuilder<CanvasBloc, CanvasState>(
                  builder: (context, canvasState) {
                    final isPlacing = canvasState.isPlacingOverlay;
                    final overlayPath = canvasState.overlayImagePath;
                    final overlayRect = canvasState.overlayRect ??
                        (isPlacing
                            ? Rect.fromLTWH(
                                drawingBounds.left + drawingBounds.width * 0.25,
                                drawingBounds.top + drawingBounds.height * 0.25,
                                drawingBounds.width * 0.5,
                                drawingBounds.height * 0.5,
                              )
                            : null);

                    if (isPlacing && canvasState.overlayRect == null && overlayRect != null) {
                      context.read<CanvasBloc>().add(UpdateOverlayRectEvent(overlayRect));
                    }

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

                    for (final placed in canvasState.placedOverlays)
                      Positioned(
                        left: placed.rect.left,
                        top: placed.rect.top,
                        width: placed.rect.width,
                        height: placed.rect.height,
                        child: Image.file(
                          File(placed.imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),

                    if (!isPlacing)
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

                    if (isPlacing && overlayPath != null && overlayRect != null)
                      _OverlayPlacement(
                        imagePath: overlayPath,
                        rect: overlayRect,
                        bounds: drawingBounds,
                        onRectChanged: (r) => context
                            .read<CanvasBloc>()
                            .add(UpdateOverlayRectEvent(r)),
                      ),
                  ],
                    );
                  },
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

class _OverlayPlacement extends StatefulWidget {
  final String imagePath;
  final Rect rect;
  final Rect bounds;
  final ValueChanged<Rect> onRectChanged;

  const _OverlayPlacement({
    required this.imagePath,
    required this.rect,
    required this.bounds,
    required this.onRectChanged,
  });

  @override
  State<_OverlayPlacement> createState() => _OverlayPlacementState();
}

class _OverlayPlacementState extends State<_OverlayPlacement> {
  late Rect _rect;
  Offset? _dragStart;
  Rect? _startRect;

  @override
  void initState() {
    super.initState();
    _rect = widget.rect;
  }

  void _notify() {
    widget.onRectChanged(_rect);
  }

  void _onDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    _startRect = _rect;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStart == null || _startRect == null) return;
    final delta = details.globalPosition - _dragStart!;
    Rect next = _startRect!.shift(delta);
    if (next.left < widget.bounds.left) {
      next = next.shift(Offset(widget.bounds.left - next.left, 0));
    }
    if (next.top < widget.bounds.top) {
      next = next.shift(Offset(0, widget.bounds.top - next.top));
    }
    if (next.right > widget.bounds.right) {
      next = next.shift(Offset(widget.bounds.right - next.right, 0));
    }
    if (next.bottom > widget.bounds.bottom) {
      next = next.shift(Offset(0, widget.bounds.bottom - next.bottom));
    }
    setState(() => _rect = next);
    _notify();
  }

  void _onResizeDrag(DragUpdateDetails details) {
    final Size minSize = Size(40, 40);
    double newWidth = (_rect.width + details.delta.dx).clamp(minSize.width, widget.bounds.width);
    double aspect = _rect.height / _rect.width;
    double newHeight = newWidth * aspect;
    Rect next = Rect.fromLTWH(_rect.left, _rect.top, newWidth, newHeight);
    if (next.right > widget.bounds.right) {
      newWidth = widget.bounds.right - _rect.left;
      newHeight = newWidth * aspect;
      next = Rect.fromLTWH(_rect.left, _rect.top, newWidth, newHeight);
    }
    if (next.bottom > widget.bounds.bottom) {
      newHeight = widget.bounds.bottom - _rect.top;
      newWidth = newHeight / aspect;
      next = Rect.fromLTWH(_rect.left, _rect.top, newWidth, newHeight);
    }
    setState(() => _rect = next);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _rect.left,
      top: _rect.top,
      width: _rect.width,
      height: _rect.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.purple, width: 1.5),
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            right: -12,
            bottom: -12,
            child: GestureDetector(
              onPanUpdate: _onResizeDrag,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.open_in_full,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
