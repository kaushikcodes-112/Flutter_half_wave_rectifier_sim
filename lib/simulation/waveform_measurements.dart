import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'rectifier_simulator.dart';

class WaveformMeasurements {
  final double vMax, vMin, vPp, vRms, vdc, piv, rippleFactor, efficiency, idc;

  const WaveformMeasurements({
    required this.vMax, required this.vMin, required this.vPp,
    required this.vRms, required this.vdc, required this.piv,
    required this.rippleFactor, required this.efficiency, required this.idc,
  });

  factory WaveformMeasurements.fromSimulation(RectifierSimulation simulation, double resistance) {
    final points = simulation.output;
    if (points.isEmpty) {
      return const WaveformMeasurements(vMax: 0, vMin: 0, vPp: 0, vRms: 0,
          vdc: 0, piv: 0, rippleFactor: 0, efficiency: 0, idc: 0);
    }
    // Exclude the first cycle so the capacitor's cold-start transient does not
    // distort steady-state readings. Sampling is uniform in simulation time.
    final period = points.last.dx / 8;
    final steady = points.where((p) => p.dx >= period).toList();
    final values = steady.map((p) => p.dy).toList();
    final n = values.length;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final dc = values.reduce((a, b) => a + b) / n;
    final rms = math.sqrt(values.fold<double>(0, (s, v) => s + v * v) / n);
    final rippleRms = math.sqrt(values.fold<double>(0, (s, v) => s + (v - dc) * (v - dc)) / n);
    var piv = 0.0;
    var inputPower = 0.0;
    // Average input power over the same steady-state interval.
    final skip = (simulation.input.length - n).clamp(0, simulation.input.length - 1);
    for (var i = skip; i < simulation.input.length; i++) {
      piv = math.max(piv, simulation.output[i].dy - simulation.input[i].dy);
      inputPower += simulation.input[i].dy * simulation.sourceCurrent[i].dy;
    }
    final avgInputPower = inputPower / (simulation.input.length - skip);
    final dcPower = dc * dc / resistance;
    return WaveformMeasurements(
      vMax: maxV, vMin: minV, vPp: maxV - minV, vRms: rms,
      vdc: dc, piv: math.max(0, piv),
      rippleFactor: dc.abs() < 1e-12 ? 0 : rippleRms / dc,
      efficiency: avgInputPower <= 0 ? 0 : dcPower / avgInputPower * 100,
      idc: dc / resistance,
    );
  }

  factory WaveformMeasurements.fromPoints(Iterable<Offset> points) {
    final values = points.map((p) => p.dy).toList();
    if (values.isEmpty) return const WaveformMeasurements(vMax: 0, vMin: 0, vPp: 0, vRms: 0, vdc: 0, piv: 0, rippleFactor: 0, efficiency: 0, idc: 0);
    final maxV = values.reduce(math.max), minV = values.reduce(math.min);
    final rms = math.sqrt(values.fold<double>(0, (s, v) => s + v * v) / values.length);
    return WaveformMeasurements(vMax: maxV, vMin: minV, vPp: maxV-minV, vRms: rms,
        vdc: values.reduce((a,b)=>a+b)/values.length, piv: 0, rippleFactor: 0, efficiency: 0, idc: 0);
  }
}
