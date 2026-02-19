import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String application = '/application';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class AppNavigator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const SizedBox());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const SizedBox());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const SizedBox());
      default:
        return MaterialPageRoute(builder: (_) => const SizedBox());
    }
  }
}
