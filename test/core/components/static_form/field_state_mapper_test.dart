import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/components/static_form/domain/field_state_mapper.dart';
import 'package:loan_poc/core/components/static_form/domain/static_form_models.dart';
import 'package:loan_poc/core/shared_services/domain/entities/los_entities.dart';

void main() {
  test(
    'FieldStateMapper maps flags and picklist options from evaluate field',
    () {
      const FieldStateMapper mapper = FieldStateMapper();
      const StaticSectionSchema schema = StaticSectionSchema(
        sectionId: 'test',
        title: 'Test',
        cards: <StaticCardSchema>[
          StaticCardSchema(
            cardId: 'c1',
            title: 'Card',
            fields: <StaticFieldSchema>[
              StaticFieldSchema(
                fieldId: 'f1',
                label: 'Field 1',
                type: StaticFieldType.dropdown,
              ),
            ],
          ),
        ],
      );

      const EvaluateSectionEntity section = EvaluateSectionEntity(
        sectionId: 'test',
        mandatory: true,
        editable: true,
        visible: true,
        status: 'PENDING',
        fields: <EvaluateFieldEntity>[
          EvaluateFieldEntity(
            fieldId: 'f1',
            type: 'DROPDOWN',
            value: null,
            mandatory: true,
            editable: false,
            visible: true,
            validation: <String, dynamic>{'minLength': 1},
            options: <String>['A', 'B'],
          ),
        ],
      );

      final mapped = mapper.map(
        schema: schema,
        evaluateSection: section,
        resolveOptions: (EvaluateFieldEntity field) => field.options,
      );

      expect(mapped['f1']?.mandatory, true);
      expect(mapped['f1']?.editable, false);
      expect(mapped['f1']?.options, <String>['A', 'B']);
    },
  );
}
