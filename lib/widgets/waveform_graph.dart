import 'package:flutter/material.dart';

class WaveformGraph extends StatefulWidget {
  final List<Offset> points;
  final String title;
  final String yAxisLabel;
  final Color traceColor;

  const WaveformGraph({
    super.key,
    required this.points,
    this.title = 'Waveform',
    this.yAxisLabel = 'Voltage (V)',
    this.traceColor = const Color(0xFF47F2B1),
  });

  @override
  State<WaveformGraph> createState() => _WaveformGraphState();
}

class _WaveformGraphState extends State<WaveformGraph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;
  double _cycles = 3;
  double _voltsPerDivision = 5;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _sweep.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sweep.stop(canceled: false);
      }
    });
    _sweep.forward();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Wrap(
        spacing: 6,
        runSpacing: 0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            tooltip: _sweep.isAnimating ? 'Pause sweep' : 'Resume sweep',
            onPressed: () => setState(() {
              if (_sweep.isAnimating) {
                _sweep.stop();
              } else if (_sweep.value < 1) {
                _sweep.forward();
              }
            }),
            icon: Icon(
              _sweep.isAnimating ? Icons.pause : Icons.play_arrow,
              color: Colors.black87,
            ),
          ),
          IconButton(
            tooltip: 'Reset sweep',
            onPressed: () {
              _sweep.reset();
              _sweep.forward();
            },
            icon: const Icon(Icons.restart_alt, color: Colors.black87),
          ),
          const Text(
            'Time/div',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          SizedBox(
            width: 90,
            child: Slider(
              value: _cycles,
              min: 1,
              max: 6,
              divisions: 5,
              onChanged: (v) => setState(() => _cycles = v),
            ),
          ),
          Text(
            '${_cycles.toStringAsFixed(0)} cyc',
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const Text(
            'Volts/div',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          SizedBox(
            width: 90,
            child: Slider(
              value: _voltsPerDivision,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => _voltsPerDivision = v),
            ),
          ),
          Text(
            '${_voltsPerDivision.toStringAsFixed(0)} V',
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
      SizedBox(
        height: 260,
        width: double.infinity,
        child: CustomPaint(
          key: ValueKey('waveform-canvas-${widget.title}'),
          painter: _ScopePainter(
            points: widget.points,
            title: widget.title,
            yAxisLabel: widget.yAxisLabel,
            color: widget.traceColor,
            progress: _sweep,
            cycles: _cycles,
            voltsPerDivision: _voltsPerDivision,
          ),
        ),
      ),
    ],
  );
}

class _ScopePainter extends CustomPainter {
  final List<Offset> points;
  final String title, yAxisLabel;
  final Color color;
  final Animation<double> progress;
  final double cycles, voltsPerDivision;
  _ScopePainter({
    required this.points,
    required this.title,
    required this.yAxisLabel,
    required this.color,
    required this.progress,
    required this.cycles,
    required this.voltsPerDivision,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(54, 30, size.width - 68, size.height - 58);
    if (rect.width <= 0 || rect.height <= 0) return;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF08151D));
    final grid = Paint()
      ..color = const Color(0xFF18333C)
      ..strokeWidth = 1;
    for (var i = 0; i <= 10; i++) {
      final x = rect.left + rect.width * i / 10;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), grid);
    }
    for (var i = 0; i <= 8; i++) {
      final y = rect.top + rect.height * i / 8;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
    }
    final axis = Paint()
      ..color = const Color(0xFF6D9295)
      ..strokeWidth = 1.3;
    canvas.drawLine(
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
      axis,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      axis,
    );
    _text(
      canvas,
      title,
      Offset(rect.left, 5),
      color: color,
      size: 14,
      bold: true,
    );
    _text(
      canvas,
      yAxisLabel,
      Offset(1, rect.top - 18),
      color: Colors.white70,
      size: 10,
    );
    _text(
      canvas,
      'Time →',
      Offset(rect.right - 39, rect.bottom + 8),
      color: Colors.white70,
      size: 10,
    );
    if (points.length > 1) {
      final duration = points.last.dx - points.first.dx;
      final visible = duration * cycles / 8;
      final start = duration - visible;
      final maxAbs = voltsPerDivision * 4;
      final path = Path();
      var started = false;
      for (final p in points) {
        if (p.dx < start) continue;
        final x = rect.left + (p.dx - start) / visible * rect.width;
        final y = rect.center.dy - p.dy / maxAbs * rect.height * .48;
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      final cutoff = rect.left + rect.width * progress.value;
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(rect.left, rect.top, cutoff, rect.bottom));
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .18)
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }
  }

  void _text(
    Canvas c,
    String value,
    Offset pos, {
    Color color = Colors.white,
    double size = 12,
    bool bold = false,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(c, pos);
  }

  @override
  bool shouldRepaint(covariant _ScopePainter old) =>
      old.points != points ||
      old.title != title ||
      old.cycles != cycles ||
      old.voltsPerDivision != voltsPerDivision ||
      old.color != color;
}
