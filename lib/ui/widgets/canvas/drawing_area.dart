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
  Rect? _startRect;
  Offset? _startFocal;
  Size? _naturalSize;

  @override
  void initState() {
    super.initState();
    _rect = widget.rect;
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final imageProvider = Image.file(File(widget.imagePath)).image;
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    ImageStreamListener? listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      _naturalSize = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      setState(() {});
      stream.removeListener(listener!);
    }, onError: (dynamic _, __) {
      if (listener != null) {
        stream.removeListener(listener!);
      }
    });
    stream.addListener(listener);
  }

  double get _imageAspect {
    if (_naturalSize == null || _naturalSize!.width == 0 || _naturalSize!.height == 0) {
      return _rect.width / _rect.height;
    }
    return _naturalSize!.width / _naturalSize!.height;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startRect = _rect;
    _startFocal = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_startRect == null || _startFocal == null) return;

    final Offset focalDelta = details.focalPoint - _startFocal!;
    Offset newCenter = _startRect!.center + focalDelta;

    final double aspect = _imageAspect; // width/height
    double newWidth = (_startRect!.width * details.scale).clamp(60.0, widget.bounds.width);
    double newHeight = newWidth / aspect;

    Rect candidate = Rect.fromCenter(center: newCenter, width: newWidth, height: newHeight);

    if (candidate.left < widget.bounds.left) {
      newCenter = Offset(widget.bounds.left + candidate.width / 2, newCenter.dy);
    }
    if (candidate.top < widget.bounds.top) {
      newCenter = Offset(newCenter.dx, widget.bounds.top + candidate.height / 2);
    }
    if (candidate.right > widget.bounds.right) {
      newCenter = Offset(widget.bounds.right - candidate.width / 2, newCenter.dy);
    }
    if (candidate.bottom > widget.bounds.bottom) {
      newCenter = Offset(newCenter.dx, widget.bounds.bottom - candidate.height / 2);
    }

    candidate = Rect.fromCenter(center: newCenter, width: newWidth, height: newHeight);

    double overflowScaleW = 1.0;
    double overflowScaleH = 1.0;
    if (candidate.width > widget.bounds.width) {
      overflowScaleW = widget.bounds.width / candidate.width;
    }
    if (candidate.height > widget.bounds.height) {
      overflowScaleH = widget.bounds.height / candidate.height;
    }
    final double overflowScale = overflowScaleW < overflowScaleH ? overflowScaleW : overflowScaleH;
    if (overflowScale < 1.0) {
      newWidth = candidate.width * overflowScale;
      newHeight = candidate.height * overflowScale;
      candidate = Rect.fromCenter(center: newCenter, width: newWidth, height: newHeight);
    }

    setState(() => _rect = candidate);
    _notify();
  }

  void _notify() {
    widget.onRectChanged(_rect);
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
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.purple, width: 1.5),
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
