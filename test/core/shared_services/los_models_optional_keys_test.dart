import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/shared_services/data/models/los_models.dart';

void main() {
  test('EvaluateFieldModel parses optional picklist keys when present', () {
    final EvaluateFieldModel model = EvaluateFieldModel.fromJson(
      <String, dynamic>{
        'fieldId': 'risk_band',
        'type': 'DROPDOWN',
        'value': 'Low',
        'mandatory': true,
        'editable': true,
        'visible': true,
        'validation': <String, dynamic>{},
        'options': <String>['Low', 'Medium', 'High'],
        'dataSource': 'BRE',
        'optionVersion': 'v2',
      },
    );

    final entity = model.toEntity();
    expect(entity.options, <String>['Low', 'Medium', 'High']);
    expect(entity.dataSource, 'BRE');
    expect(entity.optionVersion, 'v2');
  });

  test('EvaluateFieldModel keeps defaults when optional keys are absent', () {
    final EvaluateFieldModel model =
        EvaluateFieldModel.fromJson(<String, dynamic>{
          'fieldId': 'risk_band',
          'type': 'DROPDOWN',
          'value': null,
          'mandatory': false,
          'editable': true,
          'visible': true,
          'validation': <String, dynamic>{},
        });

    final entity = model.toEntity();
    expect(entity.options, isEmpty);
    expect(entity.dataSource, isNull);
    expect(entity.optionVersion, isNull);
  });
}
