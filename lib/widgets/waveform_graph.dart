import 'package:flutter/material.dart';

class WaveformGraph extends StatelessWidget {
  final List<Offset> points;
  final String title;
  final String yAxisLabel;

  const WaveformGraph({
    super.key,
    required this.points,
    this.title = 'Waveform',
    this.yAxisLabel = 'Voltage (V)',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CustomPaint(
        painter: WaveformPainter(
          points: points,
          title: title,
          yAxisLabel: yAxisLabel,
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<Offset> points;
  final String title;
  final String yAxisLabel;

  WaveformPainter({
    required this.points,
    required this.title,
    required this.yAxisLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    const leftMargin = 58.0;
    const rightMargin = 18.0;
    const topMargin = 38.0;
    const bottomMargin = 38.0;

    final graphWidth = size.width - leftMargin - rightMargin;
    final graphHeight = size.height - topMargin - bottomMargin;

    if (graphWidth <= 0 || graphHeight <= 0) {
      return;
    }

    // ------------------------------------------------------------
    // Find waveform range
    // ------------------------------------------------------------

    double minTime = 0;
    double maxTime = 1;
    double minVoltage = -1;
    double maxVoltage = 1;

    if (points.isNotEmpty) {
      minTime = points.first.dx;
      maxTime = points.first.dx;
      minVoltage = points.first.dy;
      maxVoltage = points.first.dy;

      for (final point in points) {
        if (point.dx < minTime) minTime = point.dx;
        if (point.dx > maxTime) maxTime = point.dx;
        if (point.dy < minVoltage) minVoltage = point.dy;
        if (point.dy > maxVoltage) maxVoltage = point.dy;
      }

      // Always include zero on the voltage axis.
      minVoltage = minVoltage < 0 ? minVoltage : 0;
      maxVoltage = maxVoltage > 0 ? maxVoltage : 0;

      // Add a little vertical breathing room.
      final voltageRange = maxVoltage - minVoltage;

      if (voltageRange > 0) {
        final padding = voltageRange * 0.10;
        minVoltage -= padding;
        maxVoltage += padding;
      } else {
        minVoltage -= 1;
        maxVoltage += 1;
      }
    }

    if (maxTime <= minTime) {
      maxTime = minTime + 1;
    }

    if (maxVoltage <= minVoltage) {
      maxVoltage = minVoltage + 1;
    }

    // ------------------------------------------------------------
    // Graph area
    // ------------------------------------------------------------

    final graphRect = Rect.fromLTWH(
      leftMargin,
      topMargin,
      graphWidth,
      graphHeight,
    );

    // ------------------------------------------------------------
    // Background
    // ------------------------------------------------------------

    final backgroundPaint = Paint()
      ..color = const Color(0xFFFAFBFC)
      ..style = PaintingStyle.fill;

    canvas.drawRect(graphRect, backgroundPaint);

    // ------------------------------------------------------------
    // Grid
    // ------------------------------------------------------------

    final gridPaint = Paint()
      ..color = const Color(0xFFE3E7EB)
      ..strokeWidth = 1;

    const horizontalDivisions = 4;
    const verticalDivisions = 6;

    for (int i = 0; i <= horizontalDivisions; i++) {
      final y = graphRect.top + (i / horizontalDivisions) * graphRect.height;

      canvas.drawLine(
        Offset(graphRect.left, y),
        Offset(graphRect.right, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= verticalDivisions; i++) {
      final x = graphRect.left + (i / verticalDivisions) * graphRect.width;

      canvas.drawLine(
        Offset(x, graphRect.top),
        Offset(x, graphRect.bottom),
        gridPaint,
      );
    }

    // ------------------------------------------------------------
    // Zero-voltage axis
    // ------------------------------------------------------------

    final zeroY = _mapY(0, minVoltage, maxVoltage, graphRect);

    final axisPaint = Paint()
      ..color = const Color(0xFF66717D)
      ..strokeWidth = 1.4;

    canvas.drawLine(
      Offset(graphRect.left, zeroY),
      Offset(graphRect.right, zeroY),
      axisPaint,
    );

    // ------------------------------------------------------------
    // Border
    // ------------------------------------------------------------

    final borderPaint = Paint()
      ..color = const Color(0xFFD5DAE0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(graphRect, borderPaint);

    // ------------------------------------------------------------
    // Waveform
    // ------------------------------------------------------------

    if (points.isNotEmpty) {
      final waveformPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();

      for (int i = 0; i < points.length; i++) {
        final point = points[i];

        final x = _mapX(point.dx, minTime, maxTime, graphRect);

        final y = _mapY(point.dy, minVoltage, maxVoltage, graphRect);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, waveformPaint);
    }

    // ------------------------------------------------------------
    // Labels
    // ------------------------------------------------------------

    _drawText(
      canvas,
      title,
      Offset(graphRect.left, 8),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    _drawText(
      canvas,
      yAxisLabel,
      Offset(-10, graphRect.top - 24),
      fontSize: 11,
      color: const Color(0xFF66717D),
    );

    _drawText(
      canvas,
      'Time (s)',
      Offset(graphRect.right - 20, graphRect.bottom + 22),
      fontSize: 11,
      color: const Color(0xFF66717D),
    );

    // ------------------------------------------------------------
    // Y-axis values
    // ------------------------------------------------------------

    for (int i = 0; i <= horizontalDivisions; i++) {
      final value =
          maxVoltage - (i / horizontalDivisions) * (maxVoltage - minVoltage);

      final y = graphRect.top + (i / horizontalDivisions) * graphRect.height;

      _drawText(
        canvas,
        _formatValue(value),
        Offset(8, y - 7),
        fontSize: 10,
        color: const Color(0xFF66717D),
      );
    }

    // ------------------------------------------------------------
    // X-axis values
    // ------------------------------------------------------------

    for (int i = 0; i <= verticalDivisions; i++) {
      final value = minTime + (i / verticalDivisions) * (maxTime - minTime);

      final x = graphRect.left + (i / verticalDivisions) * graphRect.width;

      final label = _formatTime(value);

      _drawTextCentered(
        canvas,
        label,
        Offset(x, graphRect.bottom + 7),
        fontSize: 10,
        color: const Color(0xFF66717D),
      );
    }
  }

  double _mapX(double value, double min, double max, Rect rect) {
    return rect.left + ((value - min) / (max - min)) * rect.width;
  }

  double _mapY(double value, double min, double max, Rect rect) {
    return rect.bottom - ((value - min) / (max - min)) * rect.height;
  }

  String _formatValue(double value) {
    if (value.abs() >= 10) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _formatTime(double value) {
    if (value.abs() < 0.001) {
      return '0';
    }

    return value.toStringAsFixed(3);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    Color color = const Color(0xFF172033),
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  void _drawTextCentered(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    Color color = const Color(0xFF172033),
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.title != title ||
        oldDelegate.yAxisLabel != yAxisLabel;
  }
}
