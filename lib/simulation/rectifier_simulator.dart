import 'dart:math';
import 'package:flutter/material.dart';

import '../models/circuit_parameters.dart';

class RectifierSimulation {
  final List<Offset> input;
  final List<Offset> output;
  final List<Offset> loadCurrent;
  final List<Offset> sourceCurrent;

  const RectifierSimulation({
    required this.input,
    required this.output,
    required this.loadCurrent,
    required this.sourceCurrent,
  });
}

class RectifierSimulator {
  final CircuitParameters parameters;

  RectifierSimulator(this.parameters);

  RectifierSimulation simulate({int samplesPerPeriod = 400, int periods = 8}) {
    final input = <Offset>[];
    final output = <Offset>[];
    final loadCurrent = <Offset>[];
    final sourceCurrent = <Offset>[];
    final count = samplesPerPeriod * periods;
    final totalTime = parameters.period * periods;
    final dt = totalTime / count;
    var capacitorVoltage = 0.0;

    for (var i = 0; i <= count; i++) {
      final t = i * dt;
      final vin = parameters.voltage * sin(2 * pi * parameters.frequency * t);
      var vout = vin > parameters.diodeVoltage
          ? vin - parameters.diodeVoltage
          : 0.0;
      var sourceAmps = vout / parameters.resistance;

      if (parameters.capacitorFilterEnabled) {
        if (i > 0) {
          // Exact RC discharge over this step, followed by ideal diode recharge.
          capacitorVoltage *= exp(-dt / (parameters.resistance * parameters.capacitance));
        }
        final available = vin - parameters.diodeVoltage;
        if (available > capacitorVoltage && vin > parameters.diodeVoltage) {
          final chargingStep = available - capacitorVoltage;
          capacitorVoltage = available;
          sourceAmps = chargingStep * parameters.capacitance / dt +
              capacitorVoltage / parameters.resistance;
        } else {
          sourceAmps = 0;
        }
        vout = capacitorVoltage;
      }

      input.add(Offset(t, vin));
      output.add(Offset(t, vout));
      loadCurrent.add(Offset(t, vout / parameters.resistance));
      sourceCurrent.add(Offset(t, sourceAmps));
    }

    return RectifierSimulation(
      input: input,
      output: output,
      loadCurrent: loadCurrent,
      sourceCurrent: sourceCurrent,
    );
  }

  List<Offset> generateInputWaveform({int samplesPerPeriod = 100, int periods = 3}) =>
      simulate(samplesPerPeriod: samplesPerPeriod, periods: periods).input;

  List<Offset> generateOutputWaveform({int samplesPerPeriod = 100, int periods = 3}) =>
      simulate(samplesPerPeriod: samplesPerPeriod, periods: periods).output;

  List<Offset> generateCurrentWaveform({int samplesPerPeriod = 100, int periods = 3}) =>
      simulate(samplesPerPeriod: samplesPerPeriod, periods: periods).loadCurrent;
}
