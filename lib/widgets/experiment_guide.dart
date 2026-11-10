import 'package:flutter/material.dart';

import '../models/experiment_reference.dart';

class ExperimentGuide extends StatelessWidget {
  const ExperimentGuide({super.key});

  @override
  Widget build(BuildContext context) => _PageColumn(
    children: [
      _card(
        'Experiment 4 · Study of Half Wave and Full Wave Rectifier',
        const Text(ExperimentReference.objective, style: _bodyStyle),
      ),
      _card('Required equipment', _bulletList(ExperimentReference.equipment)),
      _card('Components', _bulletList(ExperimentReference.components)),
      _card(
        'Experimental procedure',
        Column(
          children: [
            for (var i = 0; i < ExperimentReference.procedure.length; i++)
              _ProcedureStep(
                number: i + 1,
                text: ExperimentReference.procedure[i],
              ),
          ],
        ),
      ),
      _card(
        'Full-wave bridge conduction',
        _bulletList(ExperimentReference.fullWaveConduction),
      ),
      _WarningCard(text: ExperimentReference.scopeWarning),
    ],
  );
}

const _bodyStyle = TextStyle(height: 1.5, color: Color(0xFF4B5563));

Widget _card(String title, Widget child) => Container(
  width: double.infinity,
  margin: const EdgeInsets.only(bottom: 14),
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFDDE2E7)),
  ),
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

Widget _bulletList(List<String> items) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    for (final item in items)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '•  ',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Text(item, style: _bodyStyle)),
          ],
        ),
      ),
  ],
);

class _PageColumn extends StatelessWidget {
  final List<Widget> children;
  const _PageColumn({required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class _ProcedureStep extends StatelessWidget {
  final int number;
  final String text;
  const _ProcedureStep({required this.number, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFFEAF1FF),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: _bodyStyle)),
      ],
    ),
  );
}

class _WarningCard extends StatelessWidget {
  final String text;
  const _WarningCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7E6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF3D28B)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFF9A6700)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(height: 1.5, color: Color(0xFF674D00)),
          ),
        ),
      ],
    ),
  );
}
