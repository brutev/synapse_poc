import 'package:flutter/material.dart';

@immutable
class AppCustomColorScheme extends ThemeExtension<AppCustomColorScheme> {
  const AppCustomColorScheme({required this.primaryBrand});

  final Color primaryBrand;

  @override
  AppCustomColorScheme copyWith({Color? primaryBrand}) {
    return AppCustomColorScheme(
      primaryBrand: primaryBrand ?? this.primaryBrand,
    );
  }

  @override
  AppCustomColorScheme lerp(
    ThemeExtension<AppCustomColorScheme>? other,
    double t,
  ) {
    if (other is! AppCustomColorScheme) {
      return this;
    }
    return AppCustomColorScheme(
      primaryBrand:
          Color.lerp(primaryBrand, other.primaryBrand, t) ?? primaryBrand,
    );
  }
}
