import 'environment_config.dart';

class AppServiceUrl {
  const AppServiceUrl._();

  static String get baseUrl => EnvironmentConfig.baseUrl;

  static const String applications = '/applications';
  static const String evaluate = '/evaluate';
  static const String action = '/action';
  static const String saveDraft = '/save-draft';
  static const String submit = '/submit';
}
