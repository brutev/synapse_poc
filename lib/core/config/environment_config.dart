enum Environment { dev, qa, staging, prod }

class EnvironmentConfig {
  const EnvironmentConfig._();

  static const Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://192.168.1.5:8000';
      case Environment.qa:
        return 'https://qa.example.com';
      case Environment.staging:
        return 'https://staging.example.com';
      case Environment.prod:
        return 'https://prod.example.com';
    }
  }
}
