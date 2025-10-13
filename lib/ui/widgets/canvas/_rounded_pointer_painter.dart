import 'package:flutter/material.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class RoundedPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = AppColors.bgGray;
    final Path path = Path();
    final double radius = 3.0;

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2 - radius, radius);

    path.quadraticBezierTo(size.width / 2, 0, size.width / 2 + radius, radius);

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
