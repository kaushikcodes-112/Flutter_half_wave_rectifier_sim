import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:half_wave_rectifier/screens/simulator_screen.dart';
import 'package:half_wave_rectifier/widgets/waveform_graph.dart';

void main() {
  testWidgets('simulator tab lays out both waveform canvases', (tester) async {
    for (final size in [const Size(390, 844), const Size(1100, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const MaterialApp(home: SimulatorScreen()));
      await tester.pump(const Duration(seconds: 5));

      final graphs = find.byType(WaveformGraph);
      expect(graphs, findsNWidgets(2));
      for (final title in ['Vin(t)', 'Vout(t)']) {
        final canvasFinder = find.byKey(ValueKey('waveform-canvas-$title'));
        expect(canvasFinder, findsOneWidget);
        expect(tester.getSize(canvasFinder).width, greaterThan(0));
        expect(tester.getSize(canvasFinder).height, greaterThan(0));
      }
      expect(tester.takeException(), isNull);
    }
    await tester.binding.setSurfaceSize(null);
  });
}
