import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('app name is configured', () {
      expect(AppConfig.appName, isNotEmpty);
      expect(AppConfig.appName, equals('ZIVA LOS'));
    });
  });
}
