import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loan_poc/core/components/static_form/data/picklist_cache_service.dart';

void main() {
  test(
    'PicklistCacheService stores and retrieves options by composite key',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PicklistCacheService service = PicklistCacheService(prefs);

      await service.put(
        applicationId: 'app1',
        sectionId: 's1',
        fieldId: 'f1',
        optionVersion: 'v1',
        options: const <String>['One', 'Two'],
      );

      final List<String>? result = service.get(
        applicationId: 'app1',
        sectionId: 's1',
        fieldId: 'f1',
        optionVersion: 'v1',
      );

      expect(result, const <String>['One', 'Two']);
    },
  );
}
