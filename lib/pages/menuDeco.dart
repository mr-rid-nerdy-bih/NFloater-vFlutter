import 'package:flutter/material.dart';

class BlueprintCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawLine(Offset(cx - 15, cy), Offset(cx + 15, cy), paint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy + 15), paint);
    canvas.drawCircle(Offset(cx, cy), size.height * 0.35, paint..color = Colors.cyanAccent.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(covariant BlueprintCrosshairPainter oldDelegate) => false;
}