import 'package:flutter/material.dart';

import '../../domain/static_form_models.dart';

class StaticFieldWidget extends StatelessWidget {
  const StaticFieldWidget({
    required this.field,
    required this.state,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final StaticFieldSchema field;
  final StaticFieldRuntimeState state;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!state.visible) {
      return const SizedBox.shrink();
    }

    final String label = state.mandatory ? '${field.label} *' : field.label;

    switch (field.type) {
      case StaticFieldType.number:
        return _textField(
          label: label,
          value: value,
          enabled: state.editable,
          errorText: _errorText(),
          keyboardType: TextInputType.number,
        );
      case StaticFieldType.date:
        return _DateField(
          label: label,
          value: value?.toString() ?? '',
          enabled: state.editable,
          errorText: _errorText(),
          onChanged: onChanged,
        );
      case StaticFieldType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: value?.toString(),
          items: state.options
              .map(
                (String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: state.editable ? (String? v) => onChanged(v) : null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: _errorText(),
            helperText: state.options.isEmpty
                ? 'No options available yet'
                : null,
          ),
        );
      case StaticFieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label),
            Wrap(
              spacing: 8,
              children: state.options
                  .map(
                    (String option) => ChoiceChip(
                      label: Text(option),
                      selected: value?.toString() == option,
                      onSelected: state.editable
                          ? (_) => onChanged(option)
                          : null,
                    ),
                  )
                  .toList(),
            ),
            if (_errorText() != null)
              Text(
                _errorText()!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        );
      case StaticFieldType.checkbox:
        return CheckboxListTile(
          value: (value as bool?) ?? false,
          onChanged: state.editable ? onChanged : null,
          title: Text(label),
          subtitle: _errorText() == null
              ? null
              : Text(_errorText()!, style: const TextStyle(color: Colors.red)),
        );
      case StaticFieldType.text:
        return _textField(
          label: label,
          value: value,
          enabled: state.editable,
          errorText: _errorText(),
          keyboardType: TextInputType.text,
        );
    }
  }

  Widget _textField({
    required String label,
    required dynamic value,
    required bool enabled,
    required String? errorText,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
    );
  }

  String? _errorText() {
    final dynamic minLength = state.validation['minLength'];
    final dynamic maxLength = state.validation['maxLength'];
    final dynamic regex = state.validation['regex'];

    if (state.mandatory && (value == null || value.toString().trim().isEmpty)) {
      return '${field.label} is required';
    }

    if (value == null) {
      return null;
    }

    final String text = value.toString();
    if (minLength is int && text.length < minLength) {
      return '${field.label} must be at least $minLength characters';
    }
    if (maxLength is int && text.length > maxLength) {
      return '${field.label} must be at most $maxLength characters';
    }
    if (regex is String && regex.isNotEmpty && !RegExp(regex).hasMatch(text)) {
      return state.validation['message']?.toString() ??
          '${field.label} format is invalid';
    }

    return null;
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.errorText,
    required this.onChanged,
  });

  final String label;
  final String value;
  final bool enabled;
  final String? errorText;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enabled: enabled,
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
                initialDate: now,
                firstDate: DateTime(now.year - 50),
                lastDate: DateTime(now.year + 10),
              );
              if (selected != null) {
                onChanged(selected.toIso8601String().split('T').first);
              }
            },
    );
  }
}
