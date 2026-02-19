import 'package:flutter/material.dart';

import '../../domain/entities/form_engine_entities.dart';
import 'dynamic_field_renderer.dart';

class DynamicCardWidget extends StatelessWidget {
  const DynamicCardWidget({
    required this.card,
    required this.values,
    required this.visibility,
    required this.mandatory,
    required this.editable,
    required this.errors,
    required this.onFieldChanged,
    super.key,
  });

  final CardConfigEntity card;
  final Map<String, dynamic> values;
  final Map<String, bool> visibility;
  final Map<String, bool> mandatory;
  final Map<String, bool> editable;
  final Map<String, String?> errors;
  final void Function(String fieldId, dynamic value) onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ValueKey<String>(card.cardId),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...card.fields.map(
                (FieldConfigEntity field) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RepaintBoundary(
                    key: ValueKey<String>(field.fieldId),
                    child: DynamicFieldRenderer(
                      field: field,
                      value: values[field.fieldId],
                      visible: visibility[field.fieldId] ?? true,
                      mandatory: mandatory[field.fieldId] ?? field.mandatory,
                      editable: editable[field.fieldId] ?? field.editable,
                      errorText: errors[field.fieldId],
                      onChanged: (dynamic next) =>
                          onFieldChanged(field.fieldId, next),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
