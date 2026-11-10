import 'package:flutter/material.dart';

import '../models/circuit_parameters.dart';
import '../simulation/rectifier_simulator.dart';
import '../simulation/waveform_measurements.dart';
import '../widgets/circuit_diagram.dart';
import '../widgets/experiment_guide.dart';
import '../widgets/formula_reference.dart';
import '../widgets/observation_table.dart';
import '../widgets/parameter_controls.dart';
import '../widgets/waveform_graph.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final CircuitParameters parameters = CircuitParameters();
  late RectifierSimulator simulator;
  List<Offset> inputWaveform = [];
  List<Offset> outputWaveform = [];
  RectifierSimulation? _simulation;

  @override
  void initState() {
    super.initState();
    simulator = RectifierSimulator(parameters);
    _runSimulation();
  }

  void _runSimulation() {
    _simulation = simulator.simulate();
    inputWaveform = _simulation!.input;
    outputWaveform = _simulation!.output;
  }

  void _parametersChanged() {
    setState(_runSimulation);
  }

  Widget _buildObjective() => _buildSection(
    title: 'Objective',
    child: const Text(
      'Observe how a diode converts an AC input into a pulsating DC output, '
      'and compare the input and output waveform measurements.',
      style: TextStyle(height: 1.5, color: Color(0xFF4B5563)),
    ),
  );

  Widget _buildComponents() => _buildSection(
    title: 'Components Required',
    child: const Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _ComponentChip(label: 'AC source'),
        _ComponentChip(label: 'Step-down transformer'),
        _ComponentChip(label: 'Rectifier diode'),
        _ComponentChip(label: 'Load resistor'),
        _ComponentChip(label: 'Connecting wires'),
      ],
    ),
  );

  Widget _buildCircuitSection() => _buildSection(
    title: 'Circuit Diagram',
    child: CircuitDiagram(capacitorEnabled: parameters.capacitorFilterEnabled),
  );

  Widget _buildMeasurementSummary() {
    final output = WaveformMeasurements.fromSimulation(
      _simulation!,
      parameters.resistance,
    );

    Widget measurementRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF4B5563)),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Row(
          children: [
            Expanded(flex: 2, child: SizedBox()),
            Expanded(
              child: Text(
                'Simulated output',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 16),
        measurementRow(
          'Average DC (Vdc)',
          '${output.vdc.toStringAsFixed(3)} V',
        ),
        measurementRow(
          'RMS voltage (Vrms)',
          '${output.vRms.toStringAsFixed(3)} V',
        ),
        measurementRow(
          'Peak inverse voltage',
          '${output.piv.toStringAsFixed(3)} V',
        ),
        measurementRow('Ripple factor', output.rippleFactor.toStringAsFixed(3)),
        measurementRow(
          'Rectification efficiency',
          '${output.efficiency.toStringAsFixed(2)}%',
        ),
        measurementRow(
          'Average load current (Idc)',
          '${(output.idc * 1000).toStringAsFixed(3)} mA',
        ),
      ],
    );
  }

  Widget _buildGraphSection() => Column(
    children: [
      _buildSection(
        title: 'Input Waveform',
        child: WaveformGraph(
          points: inputWaveform,
          title: 'Vin(t)',
          yAxisLabel: 'Voltage (V)',
          traceColor: const Color(0xFF43C9FF),
        ),
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: 'Rectified Output',
        child: WaveformGraph(
          points: outputWaveform,
          title: 'Vout(t)',
          yAxisLabel: 'Voltage (V)',
          traceColor: const Color(0xFF47F2B1),
        ),
      ),
    ],
  );

  Widget _buildParametersPanel() => Column(
    children: [
      _buildSection(
        title: 'Input Parameters',
        child: ParameterControls(
          parameters: parameters,
          onChanged: _parametersChanged,
        ),
      ),
      const SizedBox(height: 16),
      _buildSection(
        title: 'Output Measurements',
        child: _buildMeasurementSummary(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: const Text(
            'Half-Wave Rectifier Simulator',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF172033),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Simulator'),
              Tab(text: 'Experiment'),
              Tab(text: 'Formula Reference'),
              Tab(text: 'Observation Table'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _KeepAlivePage(child: _buildSimulatorContent()),
            const _KeepAlivePage(child: ExperimentGuide()),
            const _KeepAlivePage(child: FormulaReferenceView()),
            const _KeepAlivePage(child: ObservationTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatorContent() => LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 1000;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildObjective(),
            const SizedBox(height: 16),
            _buildComponents(),
            const SizedBox(height: 16),
            _buildCircuitSection(),
            const SizedBox(height: 20),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildGraphSection()),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: _buildParametersPanel()),
                ],
              )
            else ...[
              _buildGraphSection(),
              const SizedBox(height: 16),
              _buildParametersPanel(),
            ],
          ],
        ),
      );
    },
  );

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE2E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _ComponentChip extends StatelessWidget {
  final String label;

  const _ComponentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.check_circle_outline, size: 18),
      label: Text(label),
      backgroundColor: const Color(0xFFF1F4F7),
      side: BorderSide.none,
      labelStyle: const TextStyle(color: Color(0xFF374151)),
    );
  }
}
