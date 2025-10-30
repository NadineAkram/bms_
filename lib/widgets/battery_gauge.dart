import 'package:flutter/material.dart';
import 'dart:math';

/// A circular gauge widget that displays the State of Charge (SoC)
/// and visually indicates if the battery is currently charging.
class BatteryGauge extends StatelessWidget {
  final double soc; // State of Charge (0.0 to 100.0)
  final bool isCharging; // New required parameter

  const BatteryGauge({
    super.key,
    required this.soc,
    required this.isCharging, // Added required parameter
  });

  @override
  Widget build(BuildContext context) {
    final double normalizedSoc = soc / 100.0;
    final Color gaugeColor = soc < 20 ? Colors.red.shade600 : (soc < 50 ? Colors.orange.shade600 : Colors.green.shade600);

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _BatteryGaugePainter(
          normalizedSoc: normalizedSoc,
          gaugeColor: gaugeColor,
          isCharging: isCharging,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${soc.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isCharging)
                const Icon(
                  Icons.flash_on,
                  color: Colors.green,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryGaugePainter extends CustomPainter {
  final double normalizedSoc;
  final Color gaugeColor;
  final bool isCharging;

  _BatteryGaugePainter({
    required this.normalizedSoc,
    required this.gaugeColor,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4; // Minus 4 for stroke

    // Background Arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi, // Start angle (top)
      2 * pi, // Sweep angle (full circle)
      false,
      backgroundPaint,
    );

    // SoC Arc
    final socPaint = Paint()
      ..color = gaugeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from the top
      2 * pi * normalizedSoc,
      false,
      socPaint,
    );

    // Charging Indicator (Subtle inner glow/ring when charging)
    if (isCharging) {
      final chargingPaint = Paint()
        ..color = Colors.lightBlue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius - 10, chargingPaint);
    }
  }

  @override
  bool shouldRepaint(_BatteryGaugePainter oldDelegate) {
    return oldDelegate.normalizedSoc != normalizedSoc ||
        oldDelegate.gaugeColor != gaugeColor ||
        oldDelegate.isCharging != isCharging;
  }
}
