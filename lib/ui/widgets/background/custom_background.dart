import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:middle_paint/gen/assets.gen.dart';
import 'package:middle_paint/base/ui_helpers/background_dimensions.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;

  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dimensions = BackgroundDimensions.of(context);
    final screenWidth = dimensions.screenWidth;
    final screenHeight = dimensions.screenHeight;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.splash.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Positioned(
            left: dimensions.leftOffset,
            top: dimensions.topPosition,
            child: Transform.rotate(
              angle: dimensions.rotationAngle,
              child: SvgPicture.asset(
                Assets.vectors.pattern,
                height: dimensions.svgScale,
              ),
            ),
          ),

          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
