import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Neon key mark from Figma app icon / join header.
class RumourKeyIcon extends StatelessWidget {
  const RumourKeyIcon({
    super.key,
    this.size = 48,
    this.color = AppColors.accent,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _KeyPainter(color),
    );
  }
}

class _KeyPainter extends CustomPainter {
  _KeyPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Head (circle) on the left
    final headCenter = Offset(w * 0.32, h * 0.5);
    final headRadius = w * 0.22;
    canvas.drawCircle(headCenter, headRadius, paint);

    // Shaft to the right
    final shaftStart = Offset(headCenter.dx + headRadius, h * 0.5);
    final shaftEnd = Offset(w * 0.88, h * 0.5);
    canvas.drawLine(shaftStart, shaftEnd, paint);

    // Teeth
    final toothPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.72, h * 0.5),
      Offset(w * 0.72, h * 0.72),
      toothPaint,
    );
    canvas.drawLine(
      Offset(w * 0.88, h * 0.5),
      Offset(w * 0.88, h * 0.68),
      toothPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KeyPainter oldDelegate) =>
      oldDelegate.color != color;
}

class RumourLogoBadge extends StatelessWidget {
  const RumourLogoBadge({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: AppColors.surfaceElevated, width: 1),
      ),
      alignment: Alignment.center,
      child: RumourKeyIcon(size: size * 0.55),
    );
  }
}
