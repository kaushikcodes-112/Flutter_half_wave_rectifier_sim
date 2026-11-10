class ExperimentReference {
  static const objective =
      'Design the half-wave and full-wave rectifier circuits, observe and record their input and output waveforms, and determine the output voltage with a filter capacitor connected across the load resistor.';

  static const equipment = [
    'Digital Multimeter',
    'Digital Storage Oscilloscope (DSO)',
    'Universal Work Station with 5 V AC supply',
  ];

  static const components = [
    'IN4007 diodes — 4',
    '1 kΩ resistor — 1',
    '100 µF capacitor — 1',
  ];

  static const procedure = [
    'Construct the circuit as shown. Use a 5 Vrms sinusoidal supply from the Universal Work Station at 50 Hz. Connect the oscilloscope probes to the input and sketch the input waveform.',
    'Connect the oscilloscope probes across the load resistor and sketch the output waveform. Measure and record the DC level of the output voltage.',
    'Connect the capacitor across the load resistor and measure the filtered output voltage.',
    'Measure the ripple voltage.',
  ];

  static const fullWaveConduction = [
    'Positive half-cycle: D2 and D3 conduct.',
    'Negative half-cycle: D1 and D4 conduct.',
  ];

  static const scopeWarning =
      'The input and output of the full-wave bridge rectifier do not share a common reference. Therefore, both cannot be viewed simultaneously on the oscilloscope using the described setup.';
}

class FormulaReferenceItem {
  final String name;
  final String expression;
  final String variables;
  final String significance;

  const FormulaReferenceItem({
    required this.name,
    required this.expression,
    required this.variables,
    required this.significance,
  });
}

class FormulaReference {
  static const manual = [
    FormulaReferenceItem(
      name: 'Form factor',
      expression: 'Form factor = Vrms / Vdc',
      variables: 'Vrms: output RMS voltage (V); Vdc: mean output voltage (V).',
      significance: 'Compares the total waveform magnitude with its useful DC level; dimensionless.',
    ),
    FormulaReferenceItem(
      name: 'Ripple factor',
      expression: 'r = √((Vrms / Vdc)² − 1)',
      variables: 'Vrms: output RMS voltage (V); Vdc: mean output voltage (V).',
      significance: 'Measures the AC ripple relative to the DC component; lower values mean smoother DC.',
    ),
    FormulaReferenceItem(
      name: 'Peak-to-peak ripple voltage',
      expression: 'Δ = Vr(p-p) = 2√3 × Vr(rms)',
      variables: 'Δ or Vr(p-p): peak-to-peak ripple (V); Vr(rms): RMS ripple voltage (V).',
      significance: 'Estimates the ripple excursion from its RMS measurement using the manual’s stated relationship.',
    ),
    FormulaReferenceItem(
      name: 'Theoretical filtered DC output voltage',
      expression: 'Vdc = Vm − Δ/2\nVdc = Vm − √3 × Vr(rms)',
      variables: 'Vm: rectified peak output voltage (V); Δ: peak-to-peak ripple (V); Vr(rms): RMS ripple voltage (V).',
      significance: 'Estimates the filtered DC level as the peak less half the peak-to-peak ripple.',
    ),
  ];

  static const additional = [
    FormulaReferenceItem(
      name: 'Average DC output (ideal half-wave)',
      expression: 'Vdc = Vm / π',
      variables: 'Vm: peak input voltage (V).',
      significance: 'Ideal, unfiltered half-wave rectifier with ideal diode and sinusoidal input.',
    ),
    FormulaReferenceItem(
      name: 'RMS output (ideal half-wave)',
      expression: 'Vrms = Vm / 2',
      variables: 'Vm: peak input voltage (V).',
      significance: 'Ideal, unfiltered half-wave output over a full cycle.',
    ),
    FormulaReferenceItem(
      name: 'Average DC output (ideal full-wave bridge)',
      expression: 'Vdc = 2Vm / π',
      variables: 'Vm: peak input voltage (V).',
      significance: 'Ideal, unfiltered full-wave bridge with ideal diodes and sinusoidal input.',
    ),
    FormulaReferenceItem(
      name: 'RMS output (ideal full-wave bridge)',
      expression: 'Vrms = Vm / √2',
      variables: 'Vm: peak input voltage (V).',
      significance: 'Ideal, unfiltered full-wave output over a full cycle.',
    ),
    FormulaReferenceItem(
      name: 'Peak inverse voltage (PIV)',
      expression: 'Half-wave: PIV = Vm\nBridge: PIV = Vm',
      variables: 'Vm: peak AC voltage across the rectifier input (V).',
      significance: 'Ideal diode assumptions; for a bridge, this is the reverse voltage per diode.',
    ),
    FormulaReferenceItem(
      name: 'Average load current',
      expression: 'Idc = Vdc / RL',
      variables: 'Vdc: mean load voltage (V); RL: load resistance (Ω); Idc: mean load current (A).',
      significance:
          'Ohm’s law applied to the DC component for a resistive load.',
    ),
    FormulaReferenceItem(
      name: 'Rectification efficiency',
      expression: 'η = (Pdc / Pac,in) × 100%\nPdc = Vdc² / RL',
      variables: 'Pdc: DC load power (W); Pac,in: average real AC source input power (W).',
      significance: 'Power conversion ratio. For an ideal unfiltered half-wave rectifier with a resistive load, ηmax = 4/π² ≈ 40.6%.',
    ),
  ];
}
