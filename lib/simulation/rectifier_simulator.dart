import 'dart:math';
import 'package:flutter/material.dart';

import '../models/circuit_parameters.dart';

class RectifierSimulator {
  final CircuitParameters parameters;

  RectifierSimulator(this.parameters);

  // Generate input waveform
  List<Offset> generateInputWaveform({
    int samplesPerPeriod = 100,
    int periods = 3,
  }) {
    final points = <Offset>[];

    final period = parameters.period;
    final totalTime = period * periods;
    final totalSamples = samplesPerPeriod * periods;

    for (int i = 0; i <= totalSamples; i++) {
      final t = (i / totalSamples) * totalTime;

      final voltage = parameters.voltage *
          sin(2 * pi * parameters.frequency * t);

      points.add(Offset(t, voltage));
    }

    return points;
  }

  // Generate half-wave rectified output
  List<Offset> generateOutputWaveform({
    int samplesPerPeriod = 100,
    int periods = 3,
  }) {
    final points = <Offset>[];

    final period = parameters.period;
    final totalTime = period * periods;
    final totalSamples = samplesPerPeriod * periods;

    for (int i = 0; i <= totalSamples; i++) {
      final t = (i / totalSamples) * totalTime;

      final inputVoltage = parameters.voltage *
          sin(2 * pi * parameters.frequency * t);

      final outputVoltage = inputVoltage > parameters.diodeVoltage
          ? inputVoltage - parameters.diodeVoltage
          : 0.0;

      points.add(Offset(t, outputVoltage));
    }

    return points;
  }

  // Generate load current waveform
  List<Offset> generateCurrentWaveform({
    int samplesPerPeriod = 100,
    int periods = 3,
  }) {
    final output = generateOutputWaveform(
      samplesPerPeriod: samplesPerPeriod,
      periods: periods,
    );

    return output.map((point) {
      final current = point.dy / parameters.resistance;

      return Offset(point.dx, current);
    }).toList();
  }
}