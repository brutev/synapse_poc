import '../../../shared_services/domain/entities/los_entities.dart';
import 'static_form_models.dart';

class FieldStateMapper {
  const FieldStateMapper();

  Map<String, StaticFieldRuntimeState> map({
    required StaticSectionSchema schema,
    required EvaluateSectionEntity evaluateSection,
    required List<String> Function(EvaluateFieldEntity evaluateField)
    resolveOptions,
  }) {
    final Map<String, EvaluateFieldEntity> evaluateByField =
        <String, EvaluateFieldEntity>{
          for (final field in evaluateSection.fields) field.fieldId: field,
        };

    final Map<String, StaticFieldRuntimeState> result =
        <String, StaticFieldRuntimeState>{};

    for (final card in schema.cards) {
      for (final field in card.fields) {
        final EvaluateFieldEntity? eval = evaluateByField[field.fieldId];
        final List<String> options = eval == null
            ? field.defaultOptions
            : resolveOptions(eval);

        result[field.fieldId] = StaticFieldRuntimeState(
          visible: eval?.visible ?? true,
          mandatory: eval?.mandatory ?? false,
          editable: eval?.editable ?? true,
          validation: eval?.validation ?? const <String, dynamic>{},
          options: options,
          dataSource: eval?.dataSource,
          optionVersion: eval?.optionVersion,
        );
      }
    }

    return result;
  }
}
