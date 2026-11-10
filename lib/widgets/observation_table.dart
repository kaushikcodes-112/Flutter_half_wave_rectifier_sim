import 'package:flutter/material.dart';

import '../models/rectifier_observation.dart';

class ObservationTable extends StatefulWidget {
  const ObservationTable({super.key});

  @override
  State<ObservationTable> createState() => _ObservationTableState();
}

class _ObservationTableState extends State<ObservationTable> {
  static const _rows = ['Half Wave Rectifier', 'Full Wave Rectifier'];
  static const _editableFields = ObservationField.values;
  late final List<Map<ObservationField, TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _rows.length,
      (_) => {
        for (final field in _editableFields) field: TextEditingController(),
      },
    );
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _clear() {
    for (final row in _controllers) {
      for (final controller in row.values) {
        controller.clear();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE2E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final description = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Observation Table',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF172033),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Enter your laboratory readings. Blue cells are calculated from your entries.',
                            style: TextStyle(color: Color(0xFF66717D)),
                          ),
                        ],
                      );
                      final clearButton = TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear entries'),
                      );
                      if (constraints.maxWidth < 560) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [description, clearButton],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: description),
                          clearButton,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 14,
                      horizontalMargin: 10,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF1F4F7),
                      ),
                      columns: const [
                        DataColumn(label: Text('Rectifier')),
                        DataColumn(label: Text('Secondary\nVrms (V)')),
                        DataColumn(label: Text('Input Vp-p\n(V)')),
                        DataColumn(label: Text('Input Vmax\n(V)')),
                        DataColumn(label: Text('Output Vm/Vmax\n(V)')),
                        DataColumn(label: Text('Output Vrms\n(V)')),
                        DataColumn(label: Text('Output Vmean/Vdc\n(V)')),
                        DataColumn(label: Text('Form factor')),
                        DataColumn(label: Text('Ripple factor')),
                        DataColumn(label: Text('Filtered DC\nmeasured (V)')),
                        DataColumn(label: Text('Ripple Vr(rms)\n(V)')),
                        DataColumn(label: Text('Δ ripple p-p\n(calculated V)')),
                        DataColumn(label: Text('Filtered DC\ntheoretical (V)')),
                      ],
                      rows: List.generate(_rows.length, _buildRow),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Theoretical filtered DC uses Vm − √3 × Vr(rms). Form and ripple factors use the unfiltered output readings.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF66717D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  DataRow _buildRow(int index) {
    final controllers = _controllers[index];
    final readings = {
      for (final entry in controllers.entries) entry.key: entry.value.text,
    };
    final calculated = ObservationCalculations.fromReadings(readings);
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 130,
            child: Text(
              _rows[index],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        _inputCell(index, ObservationField.transformerVrms),
        _inputCell(index, ObservationField.inputVpp),
        _inputCell(index, ObservationField.inputVmax),
        _inputCell(index, ObservationField.outputVm),
        _inputCell(index, ObservationField.outputVrms),
        _inputCell(index, ObservationField.outputVdc),
        _calculatedCell(calculated.formFactor),
        _calculatedCell(calculated.rippleFactor),
        _inputCell(index, ObservationField.filteredMeasuredVdc),
        _inputCell(index, ObservationField.rippleVrms),
        _calculatedCell(calculated.ripplePeakToPeak, unit: ' V'),
        _calculatedCell(calculated.theoreticalFilteredVdc, unit: ' V'),
      ],
    );
  }

  DataCell _inputCell(int row, ObservationField field) => DataCell(
    SizedBox(
      width: 100,
      child: TextField(
        controller: _controllers[row][field],
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          isDense: true,
          suffixText: 'V',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
    ),
  );

  DataCell _calculatedCell(double? value, {String unit = ''}) => DataCell(
    Container(
      width: 94,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value == null ? '—' : '${value.toStringAsFixed(3)}$unit',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF174EA6),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
