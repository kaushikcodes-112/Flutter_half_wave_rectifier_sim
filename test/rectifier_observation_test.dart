import 'package:flutter_test/flutter_test.dart';
import 'package:half_wave_rectifier/models/rectifier_observation.dart';

void main() {
  group('Observation calculations', () {
    test('calculates form factor, ripple, ripple span, and filtered DC', () {
      final result = ObservationCalculations.fromReadings({
        ObservationField.outputVrms: '5',
        ObservationField.outputVdc: '3',
        ObservationField.outputVm: '10',
        ObservationField.rippleVrms: '0.5',
      });

      expect(result.formFactor, closeTo(5 / 3, 1e-10));
      expect(result.rippleFactor, closeTo(4 / 3, 1e-10));
      expect(
        result.ripplePeakToPeak,
        closeTo(2 * 1.7320508075688772 * 0.5, 1e-10),
      );
      expect(
        result.theoreticalFilteredVdc,
        closeTo(10 - 1.7320508075688772 * 0.5, 1e-10),
      );
    });

    test(
      'empty, invalid, and physically inconsistent readings stay unavailable',
      () {
        final empty = ObservationCalculations.fromReadings({});
        expect(empty.formFactor, isNull);
        expect(empty.rippleFactor, isNull);
        expect(empty.ripplePeakToPeak, isNull);
        expect(empty.theoreticalFilteredVdc, isNull);

        final invalid = ObservationCalculations.fromReadings({
          ObservationField.outputVrms: 'NaN',
          ObservationField.outputVdc: '0',
          ObservationField.outputVm: 'Infinity',
          ObservationField.rippleVrms: '-1',
        });
        expect(invalid.formFactor, isNull);
        expect(invalid.rippleFactor, isNull);
        expect(invalid.ripplePeakToPeak, isNull);
        expect(invalid.theoreticalFilteredVdc, isNull);

        final inconsistent = ObservationCalculations.fromReadings({
          ObservationField.outputVrms: '2',
          ObservationField.outputVdc: '3',
        });
        expect(inconsistent.formFactor, closeTo(2 / 3, 1e-10));
        expect(inconsistent.rippleFactor, isNull);
      },
    );
  });
}
