import 'static_form_models.dart';

class DraftConflictResolver {
  const DraftConflictResolver();

  DraftConflictResult resolve({
    required StaticSectionSchema schema,
    required Map<String, dynamic> backendValues,
    required Map<String, dynamic> localValues,
  }) {
    final Map<String, dynamic> merged = <String, dynamic>{};
    for (final card in schema.cards) {
      for (final field in card.fields) {
        if (backendValues.containsKey(field.fieldId)) {
          // Backend is authoritative when present.
          merged[field.fieldId] = backendValues[field.fieldId];
        } else if (localValues.containsKey(field.fieldId)) {
          merged[field.fieldId] = localValues[field.fieldId];
        } else {
          merged[field.fieldId] = null;
        }
      }
    }

    return DraftConflictResult(
      values: merged,
      localBackup: Map<String, dynamic>.from(localValues),
    );
  }
}

class DraftConflictResult {
  const DraftConflictResult({required this.values, required this.localBackup});

  final Map<String, dynamic> values;
  final Map<String, dynamic> localBackup;
}
