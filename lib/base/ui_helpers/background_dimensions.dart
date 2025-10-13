import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:middle_paint/base/constants/background_constants.dart';
import 'package:middle_paint/base/ui_helpers/detect_device_type.dart';

class BackgroundDimensions {
  final double svgScale;
  final double topPosition;
  final double leftOffset;
  final double rotationAngle;
  final double screenWidth;
  final double screenHeight;

  BackgroundDimensions._({
    required this.svgScale,
    required this.topPosition,
    required this.leftOffset,
    required this.rotationAngle,
    required this.screenWidth,
    required this.screenHeight,
  });

  factory BackgroundDimensions.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final aspectRatio = mediaQuery.size.aspectRatio;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final deviceType = getDeviceType(
      shortestSide: shortestSide,
      aspectRatio: aspectRatio,
      isLandscape: isLandscape,
    );

    final scaleFactor = DesignConstants.getSvgScaleFactor(deviceType);
    final topFactor = DesignConstants.getSvgTopFactor(deviceType);
    final offset = DesignConstants.getSvgLeftOffset(deviceType);

    final angle =
        deviceType == DetectDeviceType.ipadLandscape ? -math.pi / 2 : 0.0;

    final screenW = mediaQuery.size.width;
    final screenH = mediaQuery.size.height;

    final scale = math.max(screenW, screenH) * scaleFactor;
    final topPos = screenH * topFactor;

    return BackgroundDimensions._(
      svgScale: scale,
      topPosition: topPos,
      leftOffset: offset,
      rotationAngle: angle,
      screenWidth: screenW,
      screenHeight: screenH,
    );
  }
}
