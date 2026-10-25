import 'package:flutter/material.dart';

import '../models/circuit_parameters.dart';

class ParameterControls extends StatelessWidget {
  final CircuitParameters parameters;
  final VoidCallback onChanged;

  const ParameterControls({
    super.key,
    required this.parameters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSlider(
          label: 'Input Voltage',
          value: parameters.voltage,
          displayValue:
              '${parameters.voltage.toStringAsFixed(1)} V',
          min: 1,
          max: 20,
          divisions: 190,
          onChanged: (value) {
            parameters.voltage = value;
            onChanged();
          },
        ),

        const SizedBox(height: 20),

        _buildSlider(
          label: 'Frequency',
          value: parameters.frequency,
          displayValue:
              '${parameters.frequency.toStringAsFixed(1)} Hz',
          min: 1,
          max: 1000,
          divisions: 999,
          onChanged: (value) {
            parameters.frequency = value;
            onChanged();
          },
        ),

        const SizedBox(height: 20),

        _buildSlider(
          label: 'Load Resistance',
          value: parameters.resistance,
          displayValue:
              '${parameters.resistance.toStringAsFixed(0)} Ω',
          min: 100,
          max: 10000,
          divisions: 99,
          onChanged: (value) {
            parameters.resistance = value;
            onChanged();
          },
        ),

        const SizedBox(height: 20),

        _buildSlider(
          label: 'Diode Forward Voltage',
          value: parameters.diodeVoltage,
          displayValue:
              '${parameters.diodeVoltage.toStringAsFixed(2)} V',
          min: 0,
          max: 1,
          divisions: 100,
          onChanged: (value) {
            parameters.diodeVoltage = value;
            onChanged();
          },
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Period',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                ),
              ),
              Text(
                '${(parameters.period * 1000).toStringAsFixed(2)} ms',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),

        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}