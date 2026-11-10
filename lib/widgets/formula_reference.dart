import 'package:flutter/material.dart';

import '../models/experiment_reference.dart';

class FormulaReferenceView extends StatelessWidget {
  const FormulaReferenceView({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Formulas explicitly provided in the laboratory manual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),
            for (final item in FormulaReference.manual)
              _FormulaCard(item: item),
            const SizedBox(height: 10),
            const Text(
              'Additional theoretical formulas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'These references are separate from the formulas stated in the laboratory manual.',
              style: TextStyle(color: Color(0xFF66717D)),
            ),
            const SizedBox(height: 12),
            for (final item in FormulaReference.additional)
              _FormulaCard(item: item),
          ],
        ),
      ),
    ),
  );
}

class _FormulaCard extends StatelessWidget {
  final FormulaReferenceItem item;
  const _FormulaCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
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
          item.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 9),
        SelectableText(
          item.expression,
          style: const TextStyle(
            fontSize: 17,
            height: 1.5,
            fontFamily: 'monospace',
            color: Color(0xFF174EA6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.variables,
          style: const TextStyle(height: 1.45, color: Color(0xFF4B5563)),
        ),
        const SizedBox(height: 4),
        Text(
          item.significance,
          style: const TextStyle(height: 1.45, color: Color(0xFF66717D)),
        ),
      ],
    ),
  );
}
