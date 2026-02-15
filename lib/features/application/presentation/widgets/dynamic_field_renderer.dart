import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_textformfield.dart';
import '../../domain/entities/field_entity.dart';

class DynamicFieldRenderer extends StatelessWidget {
  const DynamicFieldRenderer({
    required this.field,
    required this.onChanged,
    super.key,
  });

  final FieldEntity field;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!field.visible) {
      return const SizedBox.shrink();
    }

    final String normalizedType = field.type.toUpperCase();

    switch (normalizedType) {
      case 'DROPDOWN':
        final List<String> options =
            (field.validation['options'] as List<dynamic>? ?? <dynamic>[])
                .map((dynamic item) => item.toString())
                .toList();
        return AppDropdown(
          items: options,
          value: field.value?.toString(),
          enabled: field.editable,
          onChanged: onChanged,
        );
      case 'DATE':
        return AppTextFormField(
          initialValue: field.value?.toString() ?? '',
          label: field.fieldId,
          enabled: field.editable,
          requiredField: field.mandatory,
          onChanged: (String value) => onChanged(value),
        );
      case 'NUMBER':
        return AppTextFormField(
          initialValue: field.value?.toString() ?? '',
          label: field.fieldId,
          enabled: field.editable,
          requiredField: field.mandatory,
          keyboardType: TextInputType.number,
          onChanged: (String value) => onChanged(value),
        );
      case 'TEXT':
      case 'STRING':
      case 'BOOLEAN':
      default:
        return AppTextFormField(
          initialValue: field.value?.toString() ?? '',
          label: field.fieldId,
          enabled: field.editable,
          requiredField: field.mandatory,
          onChanged: (String value) => onChanged(value),
        );
    }
  }
}
