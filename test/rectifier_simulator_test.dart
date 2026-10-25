
import 'package:flutter_test/flutter_test.dart';
import 'package:half_wave_rectifier/models/circuit_parameters.dart';
import 'package:half_wave_rectifier/simulation/rectifier_simulator.dart';

void main() {
  group('Half-wave rectifier simulation', () {
    late CircuitParameters parameters;
    late RectifierSimulator simulator;

    setUp(() {
      parameters = CircuitParameters(
        voltage: 10,
        frequency: 50,
        resistance: 1000,
        diodeVoltage: 0.7,
      );

      simulator = RectifierSimulator(parameters);
    });

    test('period is calculated correctly', () {
      expect(parameters.period, closeTo(0.02, 0.0001));
    });

    test('input waveform starts at zero', () {
      final wave = simulator.generateInputWaveform(
        samplesPerPeriod: 100,
        periods: 1,
      );

      expect(wave.first.dy, closeTo(0, 0.0001));
    });

    test('output voltage is never negative', () {
      final wave = simulator.generateOutputWaveform(
        samplesPerPeriod: 100,
        periods: 1,
      );

      for (final point in wave) {
        expect(point.dy, greaterThanOrEqualTo(0));
      }
    });

    test('load current is non-negative', () {
      final wave = simulator.generateCurrentWaveform(
        samplesPerPeriod: 100,
        periods: 1,
      );

      for (final point in wave) {
        expect(point.dy, greaterThanOrEqualTo(0));
      }
    });
  });
}
