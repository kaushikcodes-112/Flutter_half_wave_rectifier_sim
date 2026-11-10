import 'dart:math';

import 'package:flutter/material.dart';

class CircuitDiagram extends StatelessWidget {
  final bool capacitorEnabled;
  const CircuitDiagram({super.key, this.capacitorEnabled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CustomPaint(painter: CircuitPainter(capacitorEnabled: capacitorEnabled)),
    );
  }
}

class CircuitPainter extends CustomPainter {
  final bool capacitorEnabled;
  CircuitPainter({this.capacitorEnabled = false});
  final Paint wire = Paint()
    ..color = const Color(0xFF172033)
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final Paint component = Paint()
    ..color = const Color(0xFF172033)
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final text = const TextStyle(
    color: Color(0xFF172033),
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * .52;
    final left = size.width * .12;
    final p = size.width * .32;
    final s = size.width * .46;
    final diode = size.width * .61;
    final r = size.width * .78;
    final out = size.width * .91;

    // Primary loop
    canvas.drawLine(Offset(left, y - 75), Offset(p - 30, y - 75), wire);
    canvas.drawLine(Offset(left, y + 75), Offset(p - 30, y + 75), wire);
    canvas.drawLine(Offset(left, y - 75), Offset(left, y - 30), wire);
    canvas.drawLine(Offset(left, y + 30), Offset(left, y + 75), wire);

    // AC source
    canvas.drawCircle(Offset(left, y), 30, component);
    final sine = Path();

    for (double x = -18; x <= 18; x++) {
      final yy = y - 12 * sin((x + 18) / 36 * 2 * pi);
      x == -18 ? sine.moveTo(left + x, yy) : sine.lineTo(left + x, yy);
    }

    canvas.drawPath(sine, component);

    // Primary winding
    _coil(canvas, p - 30, y);

    // Transformer core
    canvas.drawLine(Offset(p - 30, y - 75), Offset(p - 30, y - 45), wire);
    canvas.drawLine(Offset(p - 30, y + 45), Offset(p - 30, y + 75), wire);
    canvas.drawLine(Offset(s - 0, y - 75), Offset(s - 0, y - 45), wire);

    // Secondary winding
    _coil(canvas, s, y);

    // Secondary → diode
    canvas.drawLine(Offset(s - 2, y - 75), Offset(diode - 20, y - 75), wire);

    // Diode
    _diode(canvas, diode, y - 75);

    // Diode → resistor
    canvas.drawLine(Offset(diode + 10, y - 75), Offset(r, y - 75), wire);

    // Resistor
    canvas.drawLine(Offset(r - 0, y - 75), Offset(r - 0, y - 45), wire);
    _resistor(canvas, r, y - 45, y + 45);
    canvas.drawLine(Offset(r - 0, y + 75), Offset(r - 0, y + 45), wire);

    // Return path
    canvas.drawLine(Offset(r, y + 75), Offset(s + 0, y + 75), wire);
    canvas.drawLine(Offset(s + 0, y + 75), Offset(s + 0, y + 45), wire);

    // Output terminal
    canvas.drawCircle(Offset(out, y - 75), 8, component);
    canvas.drawCircle(Offset(out, y + 75), 8, component);

    canvas.drawLine(Offset(r, y - 75), Offset(out - 8, y - 75), wire);
    canvas.drawLine(Offset(r, y + 75), Offset(out - 8, y + 75), wire);

    if (capacitorEnabled) {
      final cx = r + (out - r) * .55;
      canvas.drawLine(Offset(cx, y - 75), Offset(cx, y - 10), wire);
      canvas.drawLine(Offset(cx - 14, y - 10), Offset(cx + 14, y - 10), component);
      canvas.drawLine(Offset(cx - 14, y + 10), Offset(cx + 14, y + 10), component);
      canvas.drawLine(Offset(cx, y + 10), Offset(cx, y + 75), wire);
      _label(canvas, 'C', cx + 16, y - 10);
    }

    // Labels
    _label(canvas, 'AC Mains', left - 100, y + 5);
    _label(canvas, 'Vin(t)', left - 100, y + 25);

    _label(canvas, 'P', p - 10, y + 95);
    _label(canvas, 'S', s - 5, y + 95);

    _label(canvas, 'D', diode - 7, y - 110);
    _label(canvas, 'Rₗ', r + 15, y);
    _label(canvas, 'Vout(t)', out - 30, y - 105);
  }

  void _coil(Canvas canvas, double x, double y) {
    final path = Path();

    const turns = 5;
    const width = 22.0;
    const height = 16.0;
    const spacing = 18.0;

    final top = y - (turns * spacing) / 2;

    path.moveTo(x, top);

    for (int i = 0; i < turns; i++) {
      final cy = top + i * spacing;

      path.cubicTo(x + width, cy, x + width, cy + height, x, cy + height);

      path.cubicTo(
        x - width,
        cy + height,
        x - width,
        cy + spacing,
        x,
        cy + spacing,
      );
    }

    canvas.drawPath(path, component);
  }

  void _diode(Canvas canvas, double x, double y) {
    final path = Path()
      ..moveTo(x - 20, y - 20)
      ..lineTo(x + 10, y)
      ..lineTo(x - 20, y + 20)
      ..close();

    canvas.drawPath(path, component);

    canvas.drawLine(Offset(x + 10, y - 22), Offset(x + 10, y + 22), component);
  }

  void _resistor(Canvas canvas, double x, double top, double bottom) {
    final path = Path()..moveTo(x, top);

    const steps = 6;
    final h = (bottom - top) / steps;

    for (int i = 0; i < steps; i++) {
      path.lineTo(x + (i.isEven ? 12 : -12), top + h * (i + .5));
      path.lineTo(x, top + h * (i + 1));
    }

    canvas.drawPath(path, component);
  }

  void _label(Canvas canvas, String value, double x, double y) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: text),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) =>
      oldDelegate.capacitorEnabled != capacitorEnabled;
}
