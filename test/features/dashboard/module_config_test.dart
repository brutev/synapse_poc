import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/constants/app_constants.dart';

void main() {
  test('dashboard contains 11 module tiles', () {
    expect(loanModules.length, 11);
  });
}
