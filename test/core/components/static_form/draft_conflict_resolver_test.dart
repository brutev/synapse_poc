import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/components/static_form/domain/draft_conflict_resolver.dart';
import 'package:loan_poc/core/components/static_form/domain/static_form_models.dart';

void main() {
  test('DraftConflictResolver keeps backend values as authoritative', () {
    const DraftConflictResolver resolver = DraftConflictResolver();
    const StaticSectionSchema schema = StaticSectionSchema(
      sectionId: 'test',
      title: 'Test',
      cards: <StaticCardSchema>[
        StaticCardSchema(
          cardId: 'card',
          title: 'Card',
          fields: <StaticFieldSchema>[
            StaticFieldSchema(
              fieldId: 'f1',
              label: 'Field 1',
              type: StaticFieldType.text,
            ),
          ],
        ),
      ],
    );

    final result = resolver.resolve(
      schema: schema,
      backendValues: <String, dynamic>{'f1': 'backend'},
      localValues: <String, dynamic>{'f1': 'local'},
    );

    expect(result.values['f1'], 'backend');
    expect(result.localBackup['f1'], 'local');
  });
}
