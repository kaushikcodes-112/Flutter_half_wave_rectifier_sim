import 'dart:math' as math;

import 'dart:ui' show Offset;

/// Measurements calculated from the voltage values in waveform points.
///
/// Each point's [Offset.dy] is treated as one equally weighted sample.
/// An empty point list produces zero for every measurement.
class WaveformMeasurements {
  final double vMax;
  final double vMin;
  final double vPp;
  final double vRms;

  const WaveformMeasurements({
    required this.vMax,
    required this.vMin,
    required this.vPp,
    required this.vRms,
  });

  factory WaveformMeasurements.fromPoints(Iterable<Offset> points) {
    var count = 0;
    var vMax = double.negativeInfinity;
    var vMin = double.infinity;
    var sumOfSquares = 0.0;

    for (final point in points) {
      final voltage = point.dy;
      count++;
      if (voltage > vMax) vMax = voltage;
      if (voltage < vMin) vMin = voltage;
      sumOfSquares += voltage * voltage;
    }

    if (count == 0) {
      return const WaveformMeasurements(vMax: 0, vMin: 0, vPp: 0, vRms: 0);
    }

    return WaveformMeasurements(
      vMax: vMax,
      vMin: vMin,
      vPp: vMax - vMin,
      vRms: math.sqrt(sumOfSquares / count),
    );
  }
}
