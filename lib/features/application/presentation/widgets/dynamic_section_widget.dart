import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../domain/entities/section_entity.dart';
import 'dynamic_field_renderer.dart';

class DynamicSectionWidget extends StatelessWidget {
  const DynamicSectionWidget({
    required this.section,
    required this.onFieldChanged,
    required this.onSaveDraft,
    super.key,
  });

  final SectionEntity section;
  final void Function(String fieldId, Object? value) onFieldChanged;
  final VoidCallback onSaveDraft;

  @override
  Widget build(BuildContext context) {
    if (!section.visible) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              section.sectionId,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('Status: ${section.status}'),
            const SizedBox(height: 12),
            ...section.fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DynamicFieldRenderer(
                  field: field,
                  onChanged: (Object? value) =>
                      onFieldChanged(field.fieldId, value),
                ),
              ),
            ),
            AppButton(label: 'Save Draft', onPressed: onSaveDraft),
          ],
        ),
      ),
    );
  }
}
