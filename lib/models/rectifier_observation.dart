import 'dart:math' as math;

enum ObservationField {
  transformerVrms,
  inputVpp,
  inputVmax,
  outputVm,
  outputVrms,
  outputVdc,
  filteredMeasuredVdc,
  rippleVrms,
}

class ObservationCalculations {
  final double? formFactor;
  final double? rippleFactor;
  final double? ripplePeakToPeak;
  final double? theoreticalFilteredVdc;

  const ObservationCalculations({
    required this.formFactor,
    required this.rippleFactor,
    required this.ripplePeakToPeak,
    required this.theoreticalFilteredVdc,
  });

  factory ObservationCalculations.fromReadings(
    Map<ObservationField, String> readings,
  ) {
    final vrms = _read(readings[ObservationField.outputVrms]);
    final vdc = _read(readings[ObservationField.outputVdc]);
    final vm = _read(readings[ObservationField.outputVm]);
    final rippleRms = _read(readings[ObservationField.rippleVrms]);

    double? formFactor;
    double? rippleFactor;
    if (vrms != null && vdc != null && vdc > 0) {
      formFactor = vrms / vdc;
      final ratioSquared = formFactor * formFactor;
      if (ratioSquared >= 1) rippleFactor = math.sqrt(ratioSquared - 1);
    }

    final ripplePeakToPeak = rippleRms == null ? null : 2 * _sqrt3 * rippleRms;
    final filtered = vm == null || rippleRms == null
        ? null
        : vm - _sqrt3 * rippleRms;
    return ObservationCalculations(
      formFactor: _finite(formFactor),
      rippleFactor: _finite(rippleFactor),
      ripplePeakToPeak: _finite(ripplePeakToPeak),
      theoreticalFilteredVdc: _finite(filtered),
    );
  }
}

const double _sqrt3 = 1.7320508075688772;

double? _read(String? raw) {
  final value = double.tryParse(raw?.trim() ?? '');
  return value != null && value.isFinite && value >= 0 ? value : null;
}

double? _finite(double? value) =>
    value != null && value.isFinite ? value : null;
