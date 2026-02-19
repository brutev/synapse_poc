import 'package:flutter/material.dart';

import '../../domain/static_form_models.dart';

class StaticPerformancePanel extends StatelessWidget {
  const StaticPerformancePanel({required this.metrics, super.key});

  final StaticFormMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          _Kpi(
            label: 'Evaluate',
            value: '${metrics.evaluateMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Rule Bind',
            value: '${metrics.ruleBindingMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Draft Save',
            value: '${metrics.draftSaveMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Action',
            value: '${metrics.actionMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Avg Build',
            value: '${metrics.avgBuildMs.toStringAsFixed(2)} ms',
          ),
          _Kpi(
            label: 'Avg Raster',
            value: '${metrics.avgRasterMs.toStringAsFixed(2)} ms',
          ),
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
