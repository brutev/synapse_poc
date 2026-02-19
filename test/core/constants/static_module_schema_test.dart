import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/constants/static_module_schema.dart';

void main() {
  test('static module schema contains 11 modules and 386 fields', () {
    expect(staticModuleSchemas.length, 11);

    int total = 0;
    for (final section in staticModuleSchemas.values) {
      for (final card in section.cards) {
        total += card.fields.length;
      }
    }

    expect(total, 386);
  });
}
