import 'package:flutter/material.dart';

import '../../domain/entities/form_engine_entities.dart';

class PerformancePanel extends StatelessWidget {
  const PerformancePanel({
    required this.metrics,
    required this.scenarioId,
    super.key,
  });

  final FormPerformanceMetrics metrics;
  final String scenarioId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          _Kpi(label: 'Scenario', value: scenarioId),
          _Kpi(
            label: 'Rule Eval',
            value: '${metrics.lastRuleEvalMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Save Draft',
            value: '${metrics.lastSaveMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Avg Build',
            value: '${metrics.avgBuildMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Avg Raster',
            value: '${metrics.avgRasterMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(label: 'Visible Fields', value: '${metrics.visibleFieldCount}'),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
