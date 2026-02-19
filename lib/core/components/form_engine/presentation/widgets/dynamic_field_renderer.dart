import 'package:flutter/material.dart';

import '../../domain/entities/form_engine_entities.dart';

class DynamicFieldRenderer extends StatelessWidget {
  const DynamicFieldRenderer({
    required this.field,
    required this.value,
    required this.visible,
    required this.mandatory,
    required this.editable,
    required this.errorText,
    required this.onChanged,
    super.key,
  });

  final FieldConfigEntity field;
  final dynamic value;
  final bool visible;
  final bool mandatory;
  final bool editable;
  final String? errorText;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    switch (field.type) {
      case DynamicFieldType.number:
        return _textField(
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        );
      case DynamicFieldType.date:
        return _DateField(
          label: field.label,
          initialValue: value?.toString() ?? '',
          enabled: editable,
          errorText: errorText,
          onChanged: (String val) => onChanged(val),
        );
      case DynamicFieldType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: value?.toString(),
          items: field.options
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: editable ? (String? val) => onChanged(val) : null,
          decoration: InputDecoration(
            labelText: mandatory ? '${field.label} *' : field.label,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        );
      case DynamicFieldType.checkbox:
        return CheckboxListTile(
          value: (value as bool?) ?? false,
          onChanged: editable ? onChanged : null,
          title: Text(field.label),
          subtitle: errorText == null
              ? null
              : Text(errorText!, style: const TextStyle(color: Colors.red)),
        );
      case DynamicFieldType.radio:
        final List<String> options = field.options;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(field.label),
            Wrap(
              spacing: 8,
              children: options
                  .map(
                    (String option) => ChoiceChip(
                      label: Text(option),
                      selected: value?.toString() == option,
                      onSelected: editable ? (_) => onChanged(option) : null,
                    ),
                  )
                  .toList(),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      case DynamicFieldType.text:
        return _textField(onChanged: onChanged);
    }
  }

  Widget _textField({
    TextInputType? keyboardType,
    required ValueChanged<dynamic> onChanged,
  }) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: keyboardType,
      enabled: editable,
      decoration: InputDecoration(
        labelText: mandatory ? '${field.label} *' : field.label,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.initialValue,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today_rounded),
        errorText: errorText,
      ),
      onTap: !enabled
          ? null
          : () async {
              final DateTime now = DateTime.now();
              final DateTime? selected = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 50),
                lastDate: DateTime(now.year + 10),
                initialDate: now,
              );
              if (selected != null) {
                onChanged(selected.toIso8601String().split('T').first);
              }
            },
    );
  }
}
