import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PicklistCacheService {
  PicklistCacheService(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  String _key({
    required String applicationId,
    required String sectionId,
    required String fieldId,
    required String optionVersion,
  }) {
    return 'picklist::$applicationId::$sectionId::$fieldId::$optionVersion';
  }

  Future<void> put({
    required String applicationId,
    required String sectionId,
    required String fieldId,
    required String optionVersion,
    required List<String> options,
  }) async {
    await _sharedPreferences.setString(
      _key(
        applicationId: applicationId,
        sectionId: sectionId,
        fieldId: fieldId,
        optionVersion: optionVersion,
      ),
      jsonEncode(options),
    );
  }

  List<String>? get({
    required String applicationId,
    required String sectionId,
    required String fieldId,
    required String optionVersion,
  }) {
    final String? raw = _sharedPreferences.getString(
      _key(
        applicationId: applicationId,
        sectionId: sectionId,
        fieldId: fieldId,
        optionVersion: optionVersion,
      ),
    );
    if (raw == null) {
      return null;
    }

    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List) {
      return null;
    }

    return decoded.map((dynamic e) => e.toString()).toList();
  }
}
