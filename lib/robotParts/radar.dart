import 'package:flutter/material.dart';
import 'dart:math' as math;

class ContinuousRadarPoint {
  final double angle;
  final double distanceFactor;
  double lifeAlpha;

  ContinuousRadarPoint({
    required this.angle,
    required this.distanceFactor,
    this.lifeAlpha = 1.0,
  });
}

class RadarMeshWidget extends StatefulWidget {
  const RadarMeshWidget({super.key});

  @override
  State<RadarMeshWidget> createState() => _RadarMeshWidgetState();
}

class _RadarMeshWidgetState extends State<RadarMeshWidget> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  double currentSweepAngle = -math.pi / 3;
  
  final List<ContinuousRadarPoint> activeStreamPoints = [];
  int lastDataTimestamp = 0;
  double travelingRandomDistance = 0.65;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          double t = _sweepController.value;
          currentSweepAngle = (-math.pi / 3) + (t * (2 * math.pi / 3)); 

          // 1. GRADUAL COOLDOWN ALPHA STEP
          for (var pt in activeStreamPoints) {
            pt.lifeAlpha -= 0.015; 
          }

          // 2. GARBAGE COLLECTION FLUSH: Purge completely transparent indices first
          activeStreamPoints.removeWhere((pt) => pt.lifeAlpha <= 0.0);

          // 3. HARD QUANTUM HARDWARE FIFO LIMIT: Cap array length precisely at 12 indices
          while (activeStreamPoints.length > 12) {
            activeStreamPoints.removeAt(0); // Pop oldest trace item off the bottom of stack
          }

          // 4. STEPPED TELEMETRY GENERATOR INTERCEPT
          int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          if (currentTimestamp - lastDataTimestamp >= 300) { 
            lastDataTimestamp = currentTimestamp;

            double randomStep = (_random.nextDouble() * 0.14) - 0.07;
            travelingRandomDistance += randomStep;

            if (travelingRandomDistance < 0.35) travelingRandomDistance = 0.35;
            if (travelingRandomDistance > 0.95) travelingRandomDistance = 0.95;

            double finalDistanceValue = travelingRandomDistance;
            if (_random.nextDouble() < 0.08) { 
              finalDistanceValue = 0.4 + (_random.nextDouble() * 0.1); 
            }

            double roundedAngle = double.parse(currentSweepAngle.toStringAsFixed(2));
            int existingIndex = activeStreamPoints.indexWhere((pt) => (pt.angle - roundedAngle).abs() < 0.04);

            if (existingIndex != -1) {
              activeStreamPoints[existingIndex] = ContinuousRadarPoint(
                angle: roundedAngle,
                distanceFactor: finalDistanceValue,
                lifeAlpha: 1.0,
              );
            } else {
              activeStreamPoints.add(
                ContinuousRadarPoint(
                  angle: roundedAngle, 
                  distanceFactor: finalDistanceValue,
                  lifeAlpha: 1.0,
                ),
              );
            }
          }
        });
      });
    _sweepController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: Radar3DProjectionPainter(
            sweepAngle: currentSweepAngle,
            streamPoints: activeStreamPoints,
          ),
        );
      },
    );
  }
}

class Radar3DProjectionPainter extends CustomPainter {
  final double sweepAngle;
  final List<ContinuousRadarPoint> streamPoints;

  Radar3DProjectionPainter({required this.sweepAngle, required this.streamPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.94);
    final maxRadius = size.height * 0.84; 
    const pitchFactor = 0.38; 

    final ultraThinGridPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final boundaryPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final sweepLinePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    int gridLinesCount = 10;
    for (int i = 0; i <= gridLinesCount; i++) {
      double factor = (i / gridLinesCount) * 2 - 1; 
      double gridAngle = (factor * (math.pi / 3)) - (math.pi / 2);
      double endGridX = origin.dx + maxRadius * math.cos(gridAngle);
      
      double fixY = origin.dy + (maxRadius * math.sin(gridAngle)) * pitchFactor;
      canvas.drawLine(origin, Offset(endGridX, fixY), ultraThinGridPaint);
      
      double distanceStep = maxRadius * (i / gridLinesCount);
      final transversePath = Path();
      for (double a = -math.pi / 3; a <= math.pi / 3; a += 0.05) {
        double currentAngle = a - (math.pi / 2);
        double tx = origin.dx + distanceStep * math.cos(currentAngle);
        double ty = origin.dy + (distanceStep * math.sin(currentAngle)) * pitchFactor;
        if (a == -math.pi / 3) {
          transversePath.moveTo(tx, ty);
        } else {
          transversePath.lineTo(tx, ty);
        }
      }
      canvas.drawPath(transversePath, ultraThinGridPaint);
    }

    for (double rFactor = 0.25; rFactor <= 1.0; rFactor += 0.25) {
      final currentRadius = maxRadius * rFactor;
      final path = Path();
      for (double a = -math.pi / 3; a <= math.pi / 3; a += 0.05) {
        double trackingAngle = a - (math.pi / 2); 
        double x = origin.dx + currentRadius * math.cos(trackingAngle);
        double y = origin.dy + (currentRadius * math.sin(trackingAngle)) * pitchFactor;
        if (a == -math.pi / 3) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, boundaryPaint);
    }

    List<double> edges = [-math.pi / 3, math.pi / 3];
    for (var a in edges) {
      double trackingAngle = a - (math.pi / 2);
      double targetX = origin.dx + maxRadius * math.cos(trackingAngle);
      double targetY = origin.dy + (maxRadius * math.sin(trackingAngle)) * pitchFactor;
      canvas.drawLine(origin, Offset(targetX, targetY), boundaryPaint);
    }

    double activeTrackingAngle = sweepAngle - (math.pi / 2);
    double sweepX = origin.dx + maxRadius * math.cos(activeTrackingAngle);
    double sweepY = origin.dy + (maxRadius * math.sin(activeTrackingAngle)) * pitchFactor;
    canvas.drawLine(origin, Offset(sweepX, sweepY), sweepLinePaint);

    for (var pt in streamPoints) {
      double targetAngle = pt.angle - (math.pi / 2);
      double distanceRadius = maxRadius * pt.distanceFactor;
      double targetX = origin.dx + distanceRadius * math.cos(targetAngle);
      double targetY = origin.dy + (distanceRadius * math.sin(targetAngle)) * pitchFactor;

      final livePointPaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: pt.lifeAlpha * 0.7)
        ..style = PaintingStyle.fill;
        
      final liveGlowPaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: pt.lifeAlpha * 0.12)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(targetX, targetY), 2.5, livePointPaint);
      canvas.drawCircle(Offset(targetX, targetY), 6.0, liveGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant Radar3DProjectionPainter oldDelegate) => true;
}